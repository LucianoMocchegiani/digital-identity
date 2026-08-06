import 'package:identity_core_dart/identity_core.dart';

import '../../../credentials/models/wallet_credential.dart';

/// Mapea mensajes DIDComm `offer-credential` / `issue-credential` a modelos UI.
abstract final class DidCommCredentialMapper {
  /// Preview de credencial para [AddCredentialSheet] desde un offer DIDComm.
  static WalletCredential previewFromOfferMessage(
    Map<String, dynamic> message, {
    String? issuerLabel,
  }) {
    final vc = _enrichedOfferCredential(message);

    final types = (vc?['type'] as List?)?.cast<String>() ?? const [];
    final title = types.isNotEmpty ? types.last : 'Credencial';

    final issuer = issuerLabel ??
        (vc?['issuer'] is String ? vc!['issuer'] as String : null) ??
        'Emisor DIDComm';

    final details = labeledClaimsFromOfferMessage(message)
        .map((c) => c.value?.toString() ?? '')
        .where((v) => v.isNotEmpty)
        .take(4)
        .toList(growable: false);

    return WalletCredential(
      title: title,
      issuer: issuer,
      details: details,
      // Misma señal de confianza que OID4VCI / sheet de compartir.
      verified: true,
    );
  }

  /// Claims etiqueta + valor del subject del offer (mismo layout que compartir).
  static List<LabeledClaim> labeledClaimsFromOfferMessage(
    Map<String, dynamic> message,
  ) {
    final vc = _enrichedOfferCredential(message);
    final subject = DidCommCredentialAttach.normalizeSubjectMap(
      vc?['credentialSubject'],
    );
    final claims = <LabeledClaim>[];
    for (final entry
        in ClaimDisplayResolver.subjectClaimsForDisplay(subject).entries) {
      final text = _displayValue(entry.value);
      if (text == null) continue;
      claims.add(
        LabeledClaim(
          label: ClaimDisplayResolver.humanizeClaimKey(entry.key),
          key: entry.key,
          value: text,
        ),
      );
    }
    return claims;
  }

  static Map<String, dynamic>? _enrichedOfferCredential(
    Map<String, dynamic> message,
  ) {
    final attaches = DidCommCredentialAttach.listFromMessage(message);
    final vc = DidCommCredentialAttach.credentialFromAttach(
      attaches.isNotEmpty ? attaches.first : null,
    );
    return DidCommCredentialAttach.enrichOfferDetailWithPreview(
      offerDetail: vc,
      offerMessage: message,
    );
  }

  /// Construye [W3cCredentialRecord] desde un mensaje `issue-credential`.
  static W3cCredentialRecord? recordFromIssueMessage(
    Map<String, dynamic> message, {
    required String holderDid,
    Map<String, dynamic>? offerAttach,
    Map<String, dynamic>? offerMessage,
    String? issuerLabel,
  }) {
    final attaches = DidCommCredentialAttach.listFromMessage(
      message,
      forOffer: false,
    );
    var vc = DidCommCredentialAttach.credentialFromAttach(
      attaches.isNotEmpty ? attaches.first : null,
    );
    if (vc == null) return null;

    final offerDetail = DidCommCredentialAttach.enrichOfferDetailWithPreview(
      offerDetail: offerAttach != null
          ? DidCommCredentialAttach.credentialFromAttach(offerAttach)
          : DidCommCredentialAttach.credentialFromOfferMessage(offerMessage),
      offerMessage: offerMessage,
    );
    vc = DidCommCredentialAttach.mergeIssuedCredentialWithOfferDetail(
      issued: vc,
      offerDetail: offerDetail,
    );

    final subject = ClaimDisplayResolver.subjectClaimsForDisplay(
      vc['credentialSubject'],
    );

    final types = (vc['type'] as List<dynamic>?)?.cast<String>() ?? const [];
    final issuerField = vc['issuer'];
    final issuerDid = issuerField is String
        ? issuerField
        : issuerField is Map
            ? issuerField['id'] as String?
            : null;

    return W3cCredentialRecord(
      id: 'w3c-credential-${DateTime.now().microsecondsSinceEpoch}',
      createdAt: DateTime.now().toUtc(),
      claimFormat: ClaimFormat.w3cLdp,
      credential: vc,
      types: types.isNotEmpty ? types : const ['VerifiableCredential'],
      issuerDid: issuerDid,
      holderDid: holderDid,
      displayMetadata: _displayMetadataForSubject(
        subject,
        issuerLabel: issuerLabel,
        credentialTitle: types.isNotEmpty ? types.last : null,
      ),
    );
  }

  static String? _displayValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is num || value is bool) return value.toString();
    return null;
  }

  static Map<String, dynamic>? _displayMetadataForSubject(
    Map<String, dynamic> subject, {
    String? issuerLabel,
    String? credentialTitle,
  }) {
    if (subject.isEmpty && issuerLabel == null && credentialTitle == null) {
      return null;
    }

    final claims = subject.entries
        .map(
          (e) => {
            'path': [e.key],
            'display': [
              {
                'name': ClaimDisplayResolver.humanizeClaimKey(e.key),
                'locale': 'es',
              },
            ],
          },
        )
        .toList();

    final display = <String, dynamic>{
      if (credentialTitle != null) 'name': credentialTitle,
      if (issuerLabel != null) 'issuer': {'name': issuerLabel},
      if (claims.isNotEmpty) 'credential_metadata': {'claims': claims},
    };
    return display.isEmpty ? null : display;
  }
}
