import 'reveal_frame.dart';

/// Filtra claims de UI a los pedidos por el PD (paths `$.credentialSubject.*`).
///
/// Conserva siempre `id` si estaba en la lista original (holder binding).
List<T> filterClaimsByPresentationDefinition<T>({
  required List<T> claims,
  required Map<String, dynamic> presentationDefinition,
  required String Function(T claim) claimKey,
}) {
  final paths =
      extractRevealPathsFromPresentationDefinition(presentationDefinition);
  final keys = <String>{
    for (final path in paths)
      if (RegExp(r'^\$\.credentialSubject\.([A-Za-z0-9_]+)$').hasMatch(path))
        RegExp(r'^\$\.credentialSubject\.([A-Za-z0-9_]+)$')
            .firstMatch(path)!
            .group(1)!,
  };
  if (keys.isEmpty) return claims;
  keys.add('id');
  return [
    for (final c in claims)
      if (keys.contains(claimKey(c))) c,
  ];
}
