import 'package:identity_core_dart/identity_core.dart';

import '../models/credential_display_style.dart';
import '../models/wallet_credential.dart';

/// Convierte registros del SDK y ofertas OID4VCI a [WalletCredential].
///
/// Centraliza la extracción de título, emisor, claims legibles y estilos
/// visuales desde `displayMetadata`, `issuerMetadata` y `prettyClaims` según
/// el subtipo ([SdJwtVcRecord], [W3cCredentialRecord], [MdocRecord]).
class CredentialUiMapper {
  const CredentialUiMapper._();

  /// Clave en [SdJwtVcRecord.issuerMetadata] donde se persiste el `display` del
  /// emisor (logo de marca) al enriquecer tras OID4VCI. El SDK solo guarda la
  /// configuración de la credencial, no el metadata raíz del issuer.
  static const issuerBrandDisplayKey = 'issuer_brand_display';

  /// Mapea un [CredentialRecord] almacenado a modelo de tarjeta.
  ///
  /// [WalletCredential.id] coincide con [CredentialRecord.id] para enlazar
  /// favoritas y categorías en el JSON local (`{walletId}_ux.json`).
  static WalletCredential toWalletCredential(CredentialRecord record) {
    final display = _resolveDisplayFor(record);
    final style = CredentialDisplayStyle.fromDisplayMetadata(display);

    return WalletCredential(
      id: record.id,
      title: credentialTitle(record),
      issuer: credentialIssuer(record) ?? 'Emisor desconocido',
      details: _detailsFor(record),
      logoUrl: _resolveLogoUrl(record, display),
      backgroundColor: style.backgroundColor,
      backgroundImageUrl: style.backgroundImageUrl,
      textColor: style.textColor,
      verified: true,
    );
  }

  /// Fusiona estilos de la credencial y logo del emisor antes de persistir.
  ///
  /// [identity_core_dart] guarda solo `credentialConfigurationsSupported[id]`
  /// en [SdJwtVcRecord.issuerMetadata]; el `display` raíz del issuer (logo)
  /// se pierde sin este paso post-emisión.
  static CredentialRecord enrichFromOffer(
    CredentialRecord record,
    ResolvedCredentialOffer offer, {
    String locale = 'es',
  }) {
    final credentialDisplay = _pickDisplayEntry(
          offer.credentialDisplay,
          preferredLocale: locale,
        ) ??
        _displayFromConfigurations(
          offer.issuerMetadata.credentialConfigurationsSupported,
          offer.offer.credentialConfigurationIds,
          preferredLocale: locale,
        );
    final issuerBrandDisplay = _pickDisplayEntry(
      offer.issuerMetadata.display,
      preferredLocale: locale,
    );
    final displayMetadata =
        _mergeDisplayMetadata(credentialDisplay, issuerBrandDisplay);

    return switch (record) {
      SdJwtVcRecord() => record.copyWith(
          displayMetadata: displayMetadata ?? record.displayMetadata,
          issuerMetadata: {
            ...?record.issuerMetadata,
            if (issuerBrandDisplay != null)
              issuerBrandDisplayKey: issuerBrandDisplay,
          },
        ),
      W3cCredentialRecord() => record.copyWith(
          displayMetadata: displayMetadata ?? record.displayMetadata,
        ),
      MdocRecord() => record.copyWith(
          displayMetadata: displayMetadata ?? record.displayMetadata,
        ),
      _ => record,
    };
  }

  /// Mapea una oferta OID4VCI resuelta (pre-almacenamiento) al mismo modelo.
  ///
  /// Útil en flujos de emisión para preview antes de que exista el record en
  /// Isar. Si la credencial no trae `display` en la oferta, intenta leerlo de
  /// `credentialConfigurationsSupported` del issuer metadata.
  static WalletCredential fromResolvedOffer(
    ResolvedCredentialOffer offer, {
    String locale = 'es',
  }) {
    final credentialDisplay = _pickDisplayEntry(
          offer.credentialDisplay,
          preferredLocale: locale,
        ) ??
        _displayFromConfigurations(
          offer.issuerMetadata.credentialConfigurationsSupported,
          offer.offer.credentialConfigurationIds,
          preferredLocale: locale,
        );
    final issuerDisplay = _pickDisplayEntry(
      offer.issuerMetadata.display,
      preferredLocale: locale,
    );
    final style = CredentialDisplayStyle.fromDisplayMetadata(credentialDisplay);

    final title = _nameFromDisplay(credentialDisplay) ?? 'Credencial';
    final issuer = _nameFromDisplay(issuerDisplay) ??
        _friendlyIssuerRef(offer.offer.credentialIssuer) ??
        'Emisor desconocido';

    return WalletCredential(
      title: title,
      issuer: issuer,
      details: _claimLabelsFromOffer(offer),
      logoUrl: _resolveLogoUrlFromDisplays(credentialDisplay, issuerDisplay),
      backgroundColor: style.backgroundColor,
      backgroundImageUrl: style.backgroundImageUrl,
      textColor: style.textColor,
      // Misma señal de confianza que credenciales almacenadas / sheet de compartir.
      verified: true,
    );
  }

  /// Claims etiquetados de una oferta OID4VCI (preview pre-emisión).
  ///
  /// OID4VCI no incluye valores en el offer: solo labels del metadata.
  /// Los valores aparecen tras adquirir la credencial.
  static List<LabeledClaim> labeledClaimsFromOffer(
    ResolvedCredentialOffer offer, {
    String locale = 'es',
  }) {
    for (final configId in offer.offer.credentialConfigurationIds) {
      final config =
          offer.issuerMetadata.credentialConfigurationsSupported[configId];
      Map<String, dynamic>? configMap;
      if (config is Map<String, dynamic>) {
        configMap = config;
      } else if (config is Map) {
        configMap = Map<String, dynamic>.from(config);
      }
      if (configMap == null) continue;

      final claims = ClaimDisplayResolver.orderedDisplayClaims(
        configMap,
        locale: locale,
      );
      if (claims.isNotEmpty) return claims;
    }

    return [
      for (final label in _claimLabelsFromOffer(offer))
        LabeledClaim(label: label, key: label, value: ''),
    ];
  }

  /// Título de card: `display.name` de la credencial (nunca VCT/DID).
  static String credentialTitle(
    CredentialRecord record, {
    String locale = 'es',
  }) {
    final displayName =
        _nameFromDisplay(_resolveDisplayFor(record, preferredLocale: locale));
    if (displayName != null) return displayName;

    if (record is W3cCredentialRecord) {
      final type = record.types.lastOrNull;
      if (type != null && !_looksTechnicalId(type)) return type;
    }
    return 'Credencial';
  }

  /// Emisor de card: nombre de marca OID4VCI; evita DID/URL crudos.
  ///
  /// En SD-JWT, `issuerMetadata.display` es el display de la *credencial*
  /// (config); el nombre del emisor vive en [issuerBrandDisplayKey].
  static String? credentialIssuer(CredentialRecord record) {
    if (record is SdJwtVcRecord) {
      final meta = record.issuerMetadata;
      final brandName = _nameFromDisplay(
        _asStringKeyedMap(meta?[issuerBrandDisplayKey]),
      );
      if (brandName != null) return brandName;
      return _friendlyIssuerRef(meta?['issuer'] as String?);
    }
    if (record is W3cCredentialRecord) {
      final issuerMeta = record.displayMetadata?['issuer'];
      final name = _nameFromDisplay(_asStringKeyedMap(issuerMeta));
      if (name != null) return name;
      return _friendlyIssuerRef(record.issuerDid);
    }
    return null;
  }

  static List<String> _detailsFor(CredentialRecord record) {
    if (record is SdJwtVcRecord) {
      return _stringClaims(record.prettyClaims);
    }
    if (record is W3cCredentialRecord) {
      return _stringClaims(
        ClaimDisplayResolver.subjectClaimsForDisplay(
          record.credential['credentialSubject'],
        ),
      );
    }
    return const [];
  }

  static List<String> _stringClaims(Map<String, dynamic> claims) {
    final details = <String>[];
    for (final entry in claims.entries) {
      final value = entry.value;
      if (value is String && value.isNotEmpty) {
        details.add(value);
      } else if (value is num || value is bool) {
        details.add(value.toString());
      }
    }
    return details.take(4).toList(growable: false);
  }

  static Map<String, dynamic>? _displayMetadataFor(CredentialRecord record) {
    if (record is SdJwtVcRecord) return record.displayMetadata;
    if (record is W3cCredentialRecord) return record.displayMetadata;
    if (record is MdocRecord) return record.displayMetadata;
    return null;
  }

  /// Bloque `display` de la credencial (nombre, logo, colores).
  ///
  /// Prioridad: [displayMetadata] enriquecido → `issuerMetadata.display[]`
  /// (config OID4VCI) eligiendo [preferredLocale] cuando hay varios.
  static Map<String, dynamic>? _resolveDisplayFor(
    CredentialRecord record, {
    String preferredLocale = 'es',
  }) {
    final direct = _displayMetadataFor(record);
    if (direct != null && direct.isNotEmpty) {
      // displayMetadata ya es un objeto display (no lista).
      return direct;
    }

    if (record is SdJwtVcRecord) {
      return _pickDisplayEntry(
        record.issuerMetadata?['display'],
        preferredLocale: preferredLocale,
      );
    }
    return null;
  }

  /// Resuelve la URL del logo en credenciales ya almacenadas.
  static String? _resolveLogoUrl(
    CredentialRecord record,
    Map<String, dynamic>? credentialDisplay,
  ) {
    final fromDisplay = CredentialDisplayStyle.logoUrlFromDisplay(credentialDisplay);
    if (fromDisplay != null) return fromDisplay;

    if (record is SdJwtVcRecord) {
      final meta = record.issuerMetadata;
      if (meta == null) return null;

      final brand = meta[issuerBrandDisplayKey];
      if (brand is Map) {
        final url = CredentialDisplayStyle.logoUrlFromDisplay(
          Map<String, dynamic>.from(brand),
        );
        if (url != null) return url;
      }

      return _logoUrlFromAnyDisplay(meta['display']);
    }

    return null;
  }

  static String? _resolveLogoUrlFromDisplays(
    Map<String, dynamic>? credentialDisplay,
    Map<String, dynamic>? issuerBrandDisplay,
  ) {
    return CredentialDisplayStyle.logoUrlFromDisplay(credentialDisplay) ??
        CredentialDisplayStyle.logoUrlFromDisplay(issuerBrandDisplay);
  }

  static Map<String, dynamic>? _mergeDisplayMetadata(
    Map<String, dynamic>? credentialDisplay,
    Map<String, dynamic>? issuerBrandDisplay,
  ) {
    if (credentialDisplay == null && issuerBrandDisplay == null) return null;

    final merged = <String, dynamic>{...?credentialDisplay};
    if (merged['logo'] == null && issuerBrandDisplay?['logo'] != null) {
      merged['logo'] = issuerBrandDisplay!['logo'];
    }
    return merged.isEmpty ? null : merged;
  }

  static String? _logoUrlFromAnyDisplay(dynamic display) {
    if (display is! List) return null;
    for (final entry in display) {
      if (entry is! Map) continue;
      final url = CredentialDisplayStyle.logoUrlFromDisplay(
        Map<String, dynamic>.from(entry),
      );
      if (url != null) return url;
    }
    return null;
  }

  /// Elige un entry de `display[]` priorizando [preferredLocale].
  static Map<String, dynamic>? _pickDisplayEntry(
    dynamic display, {
    String preferredLocale = 'es',
  }) {
    if (display is Map) return _asStringKeyedMap(display);
    if (display is! List || display.isEmpty) return null;

    Map<String, dynamic>? fallback;
    final preferred = preferredLocale.toLowerCase();
    for (final entry in display) {
      final map = _asStringKeyedMap(entry);
      if (map == null) continue;
      fallback ??= map;
      final locale = (map['locale'] as String?)?.toLowerCase();
      if (locale == null) continue;
      if (locale == preferred || locale.startsWith('$preferred-')) {
        return map;
      }
    }
    return fallback;
  }

  static Map<String, dynamic>? _displayFromConfigurations(
    Map<String, dynamic> configurations,
    List<String> configurationIds, {
    String preferredLocale = 'es',
  }) {
    for (final configId in configurationIds) {
      final config = configurations[configId];
      if (config is! Map) continue;
      final picked = _pickDisplayEntry(
        config['display'],
        preferredLocale: preferredLocale,
      );
      if (picked != null) return picked;
    }
    return null;
  }

  static String? _nameFromDisplay(Map<String, dynamic>? display) {
    final name = display?['name'];
    if (name is String && name.trim().isNotEmpty) return name.trim();
    return null;
  }

  static Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  /// Host legible para HTTPS; `null` si es DID u otro id técnico.
  static String? _friendlyIssuerRef(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final value = raw.trim();
    if (value.toLowerCase().startsWith('did:')) return null;
    final uri = Uri.tryParse(value);
    if (uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty) {
      return uri.host.replaceFirst(RegExp(r'^www\.'), '');
    }
    if (_looksTechnicalId(value)) return null;
    return value;
  }

  static bool _looksTechnicalId(String value) {
    final v = value.toLowerCase();
    if (v.startsWith('urn:')) return true;
    if (v.startsWith('did:')) return true;
    if (v.contains('europa.ec')) return true;
    if (v.contains(':') && v.contains('.')) return true;
    return false;
  }

  /// Claims con etiquetas legibles desde metadata OID4VCI del issuer.
  static List<LabeledClaim> labeledClaimsFor(
    CredentialRecord record, {
    String? locale,
  }) {
    return ClaimDisplayResolver.resolve(record, locale: locale);
  }

  /// Filtra [claims] según las rutas de disclosures seleccionadas (OID4VP).
  ///
  /// Matchea cada ruta por su último segmento contra [LabeledClaim.key],
  /// preservando el orden de [paths]. Una ruta sin claim resuelto produce una
  /// etiqueta humanizada sin valor (misma convención que Añadir para claims
  /// sin dato).
  static List<LabeledClaim> claimsForDisclosurePaths(
    List<LabeledClaim> claims,
    List<String> paths,
  ) {
    return [
      for (final path in paths)
        claims.firstWhere(
          (c) => c.key == path.split('.').last,
          orElse: () => LabeledClaim(
            label: ClaimDisplayResolver.humanizeClaimKey(path.split('.').last),
            key: path.split('.').last,
            value: '',
          ),
        ),
    ];
  }

  static List<String> _claimLabelsFromOffer(ResolvedCredentialOffer offer) {
    for (final configId in offer.offer.credentialConfigurationIds) {
      final config =
          offer.issuerMetadata.credentialConfigurationsSupported[configId];
      if (config is Map<String, dynamic>) {
        final labels = ClaimDisplayResolver.orderedDisplayLabels(config);
        if (labels.isNotEmpty) return labels;
      } else if (config is Map) {
        final labels = ClaimDisplayResolver.orderedDisplayLabels(
          Map<String, dynamic>.from(config),
        );
        if (labels.isNotEmpty) return labels;
      }
    }

    final credentialDisplay = offer.credentialDisplay?.firstOrNull ??
        _displayFromConfigurations(
          offer.issuerMetadata.credentialConfigurationsSupported,
          offer.offer.credentialConfigurationIds,
        );
    return _claimNamesFromDisplay(credentialDisplay);
  }

  static List<String> _claimNamesFromDisplay(Map<String, dynamic>? display) {
    if (display == null) return const [];
    final claims = display['claims'];
    if (claims is! List) return const [];

    final names = <String>[];
    for (final claim in claims) {
      if (claim is! Map<String, dynamic>) continue;
      final displayList = claim['display'];
      if (displayList is List && displayList.isNotEmpty) {
        final name = displayList.first['name'] as String?;
        if (name != null) names.add(name);
      } else {
        final path = claim['path'];
        if (path is List && path.isNotEmpty) names.add(path.last.toString());
      }
    }
    return names;
  }
}
