/// Claim resuelto para UI con etiqueta legible y valor del token.
class LabeledClaim {
  const LabeledClaim({
    required this.label,
    required this.key,
    required this.value,
  });

  /// Etiqueta para mostrar (metadata del issuer o fallback humanizado).
  final String label;

  /// Clave o ruta técnica del claim (último segmento del `path` OID4VCI).
  final String key;

  /// Valor del claim en la credencial almacenada.
  final dynamic value;
}
