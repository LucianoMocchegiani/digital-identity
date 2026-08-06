import 'sd_jwt_parser.dart';

/// Herramientas de selective disclosure para SD-JWT.
///
/// Permite reconstruir todos los claims de un token, seleccionar un subconjunto
/// de disclosures por claim paths y construir el SD-JWT presentado.
class SdJwtSelector {
  /// Reconstruye el mapa de claims completo aplicando todos los disclosures.
  ///
  /// Reemplaza recursivamente los arrays `_sd` del payload con los claims
  /// correspondientes a cada disclosure. También procesa elementos de arrays
  /// con el operador `{"...": hash}`.
  static Map<String, dynamic> reconstructClaims(SdJwtToken token) {
    final hashMap = _buildHashMap(token.disclosures);
    return _applyDisclosures(token.payload, hashMap);
  }

  /// Filtra [requestedPaths] a claims que quedan revelados tras selective disclosure.
  ///
  /// No usa el mapa completo de claims (todos los disclosures): solo incluye
  /// rutas que la presentación parcial realmente puede mostrar.
  static List<String> filterPresentableClaimPaths({
    required SdJwtToken token,
    required List<String> requestedPaths,
  }) {
    if (requestedPaths.isEmpty) return const [];

    final accepted = <String>[];

    for (final path in requestedPaths) {
      final disclosures = selectDisclosuresForPaths(token, [...accepted, path]);
      final revealed = reconstructClaims(
        SdJwtToken(
          issuerJwt: token.issuerJwt,
          header: token.header,
          payload: token.payload,
          disclosures: disclosures,
          keyBindingJwt: token.keyBindingJwt,
        ),
      );
      if (_hasPresentableValueAtPath(revealed, path)) {
        accepted.add(path);
      }
    }

    return accepted;
  }

  static bool _hasPresentableValueAtPath(
    Map<String, dynamic> claims,
    String path,
  ) {
    dynamic current = claims;
    for (final segment in path.split('.')) {
      if (current is! Map) return false;
      current = current[segment];
    }
    return _isPresentableValue(current);
  }

  static bool _isPresentableValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  /// Selecciona disclosures para varias rutas DCQL/OID4VP sin duplicar.
  ///
  /// Si una ruta es un contenedor de array (`nationalities`) o comodín DCQL,
  /// incluye los disclosures de elementos referenciados en el payload.
  static List<Disclosure> selectDisclosuresForPaths(
    SdJwtToken token,
    List<String> claimPaths,
  ) {
    final selected = <Disclosure>[];
    final seen = <String>{};

    void addAll(Iterable<Disclosure> disclosures) {
      for (final disclosure in disclosures) {
        if (seen.add(disclosure.encoded)) {
          selected.add(disclosure);
        }
      }
    }

    for (final path in claimPaths) {
      addAll(selectDisclosures(token, [path]));
      if (_disclosuresForContainer(token, path).isNotEmpty) {
        addAll(_disclosuresForContainer(token, path));
      }
    }

    return selected;
  }

  /// Disclosures de un contenedor (objeto con `_sd` o array con `{"...": hash}`).
  static List<Disclosure> _disclosuresForContainer(
    SdJwtToken token,
    String containerPath,
  ) {
    final value = _valueAtPath(token.payload, containerPath);
    if (value == null) {
      final pathMap = _buildPathToDisclosureMap(token);
      final prefix = '$containerPath.';
      return pathMap.entries
          .where((e) => e.key == containerPath || e.key.startsWith(prefix))
          .map((e) => e.value)
          .toList();
    }

    if (value is List) {
      final hashes = <String>{};
      for (final item in value) {
        if (item is Map && item['...'] is String) {
          hashes.add(item['...'] as String);
        }
      }
      return token.disclosures.where((d) => hashes.contains(d.hash)).toList();
    }

    if (value is Map<String, dynamic> && value['_sd'] is List) {
      final hashMap = _buildHashMap(token.disclosures);
      final result = <Disclosure>[];
      for (final hash in value['_sd'] as List) {
        if (hash is! String) continue;
        final disclosure = hashMap[hash];
        if (disclosure != null) result.add(disclosure);
      }
      return result;
    }

    return [];
  }

  static dynamic _valueAtPath(Map<String, dynamic> obj, String path) {
    dynamic current = obj;
    for (final segment in path.split('.')) {
      if (current is! Map) return null;
      current = current[segment];
    }
    return current;
  }

  /// Selecciona los [Disclosure]s necesarios para los [claimPaths] solicitados.
  ///
  /// [claimPaths] es una lista de rutas de claim con notación punto,
  /// ej. `['given_name', 'address.street_address']`.
  ///
  /// Retorna solo los disclosures que proveen esas rutas. Si un path no
  /// está disponible como disclosure (claim fijo), se ignora silenciosamente.
  static List<Disclosure> selectDisclosures(
    SdJwtToken token,
    List<String> claimPaths,
  ) {
    final pathMap = _buildPathToDisclosureMap(token);
    final selected = <Disclosure>[];
    final seen = <String>{};

    for (final path in claimPaths) {
      final disclosure = _disclosureForPath(path, pathMap);
      if (disclosure != null && !seen.contains(disclosure.encoded)) {
        selected.add(disclosure);
        seen.add(disclosure.encoded);
      }
    }

    return selected;
  }

  /// Disclosure exacto o del ancestro más cercano (objeto anidado en SD-JWT).
  static Disclosure? _disclosureForPath(
    String path,
    Map<String, Disclosure> pathMap,
  ) {
    if (pathMap.containsKey(path)) return pathMap[path];

    final segments = path.split('.');
    for (var i = segments.length - 1; i >= 1; i--) {
      final parent = segments.sublist(0, i).join('.');
      final parentDisclosure = pathMap[parent];
      if (parentDisclosure != null) return parentDisclosure;
    }

    return null;
  }

  /// Construye el SD-JWT presentado con solo los [selected] disclosures.
  ///
  /// Formato resultante: `{issuer-jwt}~{disc1}~{disc2}~...~`
  /// El `~` al final indica que no hay kb-JWT; [buildWithKeyBinding] agrega el kb-JWT.
  static String buildPresented(SdJwtToken token, List<Disclosure> selected) {
    final selectedEncoded = {for (final d in selected) d.encoded};
    final parts = <String>[token.issuerJwt];
    for (final disclosure in token.disclosures) {
      if (selectedEncoded.contains(disclosure.encoded)) {
        parts.add(disclosure.encoded);
      }
    }
    parts.add(''); // trailing ~ sin kb-jwt
    return parts.join('~');
  }

  /// Construye el SD-JWT presentado y agrega el [keyBindingJwt] al final.
  ///
  /// Formato: `{issuer-jwt}~{disc1}~...~{kb-jwt}`
  static String buildWithKeyBinding(
    SdJwtToken token,
    List<Disclosure> selected,
    String keyBindingJwt,
  ) {
    final selectedEncoded = {for (final d in selected) d.encoded};
    final parts = <String>[token.issuerJwt];
    for (final disclosure in token.disclosures) {
      if (selectedEncoded.contains(disclosure.encoded)) {
        parts.add(disclosure.encoded);
      }
    }
    parts.add(keyBindingJwt);
    return parts.join('~');
  }

  // — helpers privados —

  static Map<String, Disclosure> _buildHashMap(List<Disclosure> disclosures) {
    return {for (final d in disclosures) d.hash: d};
  }

  /// Aplica disclosures a [obj] recursivamente, reemplazando arrays `_sd`.
  static Map<String, dynamic> _applyDisclosures(
    Map<String, dynamic> obj,
    Map<String, Disclosure> hashMap,
  ) {
    final result = <String, dynamic>{};

    for (final entry in obj.entries) {
      if (entry.key == '_sd' || entry.key == '_sd_alg') continue;

      final value = entry.value;
      if (value is Map<String, dynamic>) {
        result[entry.key] = _applyDisclosures(value, hashMap);
      } else if (value is List) {
        result[entry.key] = _processList(value, hashMap);
      } else {
        result[entry.key] = value;
      }
    }

    // Expandir los claims en el array _sd de este nivel
    final sd = obj['_sd'];
    if (sd is List) {
      for (final hash in sd) {
        if (hash is! String) continue;
        final disclosure = hashMap[hash];
        if (disclosure == null || disclosure.isArrayElement) continue;

        final value = disclosure.claimValue;
        result[disclosure.claimName] = value is Map<String, dynamic>
            ? _applyDisclosures(value, hashMap)
            : value;
      }
    }

    return result;
  }

  static List<dynamic> _processList(List<dynamic> list, Map<String, Disclosure> hashMap) {
    final result = <dynamic>[];
    for (final item in list) {
      if (item is Map<String, dynamic> && item.containsKey('...')) {
        // Elemento de array con spread disclosure: {"...": hash}
        final hash = item['...'] as String?;
        if (hash != null) {
          final disclosure = hashMap[hash];
          if (disclosure != null) result.add(disclosure.claimValue);
        }
      } else if (item is Map<String, dynamic>) {
        result.add(_applyDisclosures(item, hashMap));
      } else {
        result.add(item);
      }
    }
    return result;
  }

  /// Construye un mapa de ruta completa de claim → disclosure.
  ///
  /// Ej. `{'given_name': Disclosure, 'address.street_address': Disclosure}`
  static Map<String, Disclosure> _buildPathToDisclosureMap(SdJwtToken token) {
    final hashMap = _buildHashMap(token.disclosures);
    final result = <String, Disclosure>{};
    _walkForPaths(token.payload, hashMap, '', result);
    return result;
  }

  static void _walkForPaths(
    Map<String, dynamic> obj,
    Map<String, Disclosure> hashMap,
    String prefix,
    Map<String, Disclosure> result,
  ) {
    // Registrar disclosures en el array _sd de este nivel
    final sd = obj['_sd'];
    if (sd is List) {
      for (final hash in sd) {
        if (hash is! String) continue;
        final disclosure = hashMap[hash];
        if (disclosure == null || disclosure.isArrayElement) continue;

        final path = prefix.isEmpty
            ? disclosure.claimName
            : '$prefix.${disclosure.claimName}';
        result[path] = disclosure;

        // Si el valor del disclosure es a su vez un objeto con _sd, recursar
        if (disclosure.claimValue is Map<String, dynamic>) {
          _walkForPaths(
            disclosure.claimValue as Map<String, dynamic>,
            hashMap,
            path,
            result,
          );
        }
      }
    }

    // Recursar en objetos fijos (no provenientes de _sd)
    for (final entry in obj.entries) {
      if (entry.key == '_sd' || entry.key == '_sd_alg') continue;
      if (entry.value is Map<String, dynamic>) {
        final path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
        _walkForPaths(
          entry.value as Map<String, dynamic>,
          hashMap,
          path,
          result,
        );
      }
    }
  }
}
