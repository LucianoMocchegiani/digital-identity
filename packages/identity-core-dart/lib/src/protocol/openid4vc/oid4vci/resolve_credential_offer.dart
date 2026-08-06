import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../invitation/invitation_normalizer.dart';
import '../../../invitation/invitation_parser.dart';
import 'models/credential_offer.dart';
import 'models/issuer_metadata.dart';
import 'oauth_server_metadata.dart';

part 'resolve_credential_offer.freezed.dart';

/// Flujo OID4VCI detectado al resolver el offer.
enum Oid4VciFlow {
  /// Pre-authorized code sin código de transacción.
  preAuth,

  /// Pre-authorized code con código de transacción (e.g. PIN de 4 dígitos).
  preAuthWithTxCode,

  /// Authorization code (requiere PKCE).
  authCode,
}

/// Offer resuelto con metadatos del issuer y flujo detectado.
@freezed
class ResolvedCredentialOffer with _$ResolvedCredentialOffer {
  const factory ResolvedCredentialOffer({
    required CredentialOffer offer,
    required IssuerMetadata issuerMetadata,
    required Oid4VciFlow flow,

    /// Metadatos de display crudos de las credenciales ofrecidas.
    List<Map<String, dynamic>>? credentialDisplay,
  }) = _ResolvedCredentialOffer;
}

/// Parsea y resuelve un URI de credential offer.
///
/// Formatos soportados:
/// - `openid-credential-offer://?credential_offer={json}`
/// - `openid-credential-offer://?credential_offer_uri={url}`
///
/// Pasos:
/// 1. Parsear el URI y obtener el JSON del offer.
/// 2. Si hay `credential_offer_uri`, hacer GET para obtener el JSON.
/// 3. GET `{issuer}/.well-known/openid-credential-issuer` para obtener metadatos.
/// 4. Detectar el flujo (preAuth, preAuthWithTxCode, authCode).
Future<ResolvedCredentialOffer> resolveCredentialOffer(
  String offerUri, {
  Dio? dio,
}) async {
  final client = dio ?? Dio();
  final canonicalUri = InvitationParser.canonicalizeForResolve(offerUri);
  final offer = await _parseOfferUri(canonicalUri, client);
  var issuerMetadata = await _fetchIssuerMetadata(offer.credentialIssuer, client);
  final flow = _detectFlow(offer);

  if (flow == Oid4VciFlow.authCode ||
      issuerMetadata.tokenEndpoint == null ||
      issuerMetadata.tokenEndpoint!.isEmpty) {
    issuerMetadata = await enrichIssuerMetadataWithAuthorizationServer(
      metadata: issuerMetadata,
      offer: offer,
      dio: client,
    );
  }

  final display = _extractCredentialDisplay(offer, issuerMetadata);

  return ResolvedCredentialOffer(
    offer: offer,
    issuerMetadata: issuerMetadata,
    flow: flow,
    credentialDisplay: display,
  );
}

Future<CredentialOffer> _parseOfferUri(String offerUri, Dio client) async {
  final normalized = normalizeInvitationUrl(offerUri);

  if (isInlineCredentialOfferJson(normalized)) {
    final json = jsonDecode(normalized) as Map<String, dynamic>;
    return CredentialOffer.fromJson(json);
  }

  final uri = Uri.parse(normalized);
  final params = uri.queryParameters;

  if (params.containsKey('credential_offer')) {
    final json = jsonDecode(params['credential_offer']!) as Map<String, dynamic>;
    return CredentialOffer.fromJson(json);
  }

  if (params.containsKey('credential_offer_uri')) {
    final response = await client.get<Map<String, dynamic>>(
      params['credential_offer_uri']!,
    );
    return CredentialOffer.fromJson(response.data!);
  }

  // URL HTTPS directa al endpoint del offer (sin query OID4VCI).
  if (uri.scheme == 'https') {
    final lower = offerUri.toLowerCase();
    if (lower.contains('credential-offer') ||
        lower.contains('credential_offer')) {
      final response = await client.get<Map<String, dynamic>>(offerUri.trim());
      return CredentialOffer.fromJson(response.data!);
    }
  }

  throw const FormatException(
    'URI de credential offer inválido: ni credential_offer ni credential_offer_uri encontrado.',
  );
}

Future<IssuerMetadata> _fetchIssuerMetadata(String issuerUrl, Dio client) async {
  final metadataUrl = '$issuerUrl/.well-known/openid-credential-issuer';
  final response = await client.get<Map<String, dynamic>>(metadataUrl);
  return IssuerMetadata.fromJson(response.data!);
}

Oid4VciFlow _detectFlow(CredentialOffer offer) {
  final preAuth = offer.grants?.preAuthorized;
  if (preAuth != null) {
    return preAuth.txCode != null ? Oid4VciFlow.preAuthWithTxCode : Oid4VciFlow.preAuth;
  }

  if (offer.grants?.authCode != null) return Oid4VciFlow.authCode;

  // Por defecto se asume pre-auth si no hay grants explícitos
  return Oid4VciFlow.preAuth;
}

List<Map<String, dynamic>>? _extractCredentialDisplay(
  CredentialOffer offer,
  IssuerMetadata metadata,
) {
  final configs = metadata.credentialConfigurationsSupported;
  final result = <Map<String, dynamic>>[];

  for (final configId in offer.credentialConfigurationIds) {
    final config = configs[configId];
    if (config is Map<String, dynamic>) {
      final display = config['display'];
      if (display is List) {
        result.addAll(display.whereType<Map<String, dynamic>>());
      }
    }
  }

  return result.isEmpty ? null : result;
}
