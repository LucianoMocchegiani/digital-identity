/// Atributo formateado de una credencial, listo para renderizar en UI.
///
/// Jerarquía sellada: [FormattedAttributeString], [FormattedAttributeNumber],
/// [FormattedAttributeDate], [FormattedAttributeBool], [FormattedAttributeArray],
/// [FormattedAttributeObject].
sealed class FormattedAttribute {
  /// Nombre del atributo (claim path).
  String get key;

  /// Etiqueta localizada del atributo, si está disponible en la metadata del issuer.
  String? get label;
}

/// Atributo de tipo texto.
final class FormattedAttributeString implements FormattedAttribute {
  @override
  final String key;

  @override
  final String? label;

  /// Valor del atributo como cadena de texto.
  final String value;

  const FormattedAttributeString({
    required this.key,
    required this.value,
    this.label,
  });
}

/// Atributo de tipo numérico.
final class FormattedAttributeNumber implements FormattedAttribute {
  @override
  final String key;

  @override
  final String? label;

  /// Valor del atributo como número.
  final num value;

  const FormattedAttributeNumber({
    required this.key,
    required this.value,
    this.label,
  });
}

/// Atributo de tipo fecha/hora.
final class FormattedAttributeDate implements FormattedAttribute {
  @override
  final String key;

  @override
  final String? label;

  /// Valor del atributo como [DateTime].
  final DateTime value;

  const FormattedAttributeDate({
    required this.key,
    required this.value,
    this.label,
  });
}

/// Atributo de tipo booleano.
final class FormattedAttributeBool implements FormattedAttribute {
  @override
  final String key;

  @override
  final String? label;

  /// Valor del atributo.
  final bool value;

  const FormattedAttributeBool({
    required this.key,
    required this.value,
    this.label,
  });
}

/// Atributo de tipo lista de valores.
final class FormattedAttributeArray implements FormattedAttribute {
  @override
  final String key;

  @override
  final String? label;

  /// Elementos de la lista, cada uno como [FormattedAttribute].
  final List<FormattedAttribute> items;

  const FormattedAttributeArray({
    required this.key,
    required this.items,
    this.label,
  });
}

/// Atributo de tipo objeto anidado.
final class FormattedAttributeObject implements FormattedAttribute {
  @override
  final String key;

  @override
  final String? label;

  /// Atributos hijos del objeto.
  final List<FormattedAttribute> children;

  const FormattedAttributeObject({
    required this.key,
    required this.children,
    this.label,
  });
}
