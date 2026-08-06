import 'dart:typed_data';

/// Alfabeto Bitcoin utilizado por base58btc (multibase `z`).
const _alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

/// Codifica [bytes] en base58btc y devuelve el resultado sin el prefijo `z`.
String encodeBase58Btc(Uint8List bytes) {
  var leadingZeros = 0;
  for (final b in bytes) {
    if (b != 0) break;
    leadingZeros++;
  }

  var value = BigInt.zero;
  for (final b in bytes) {
    value = value * BigInt.from(256) + BigInt.from(b);
  }

  final buf = StringBuffer();
  while (value > BigInt.zero) {
    final rem = (value % BigInt.from(58)).toInt();
    buf.write(_alphabet[rem]);
    value ~/= BigInt.from(58);
  }

  for (var i = 0; i < leadingZeros; i++) {
    buf.write(_alphabet[0]);
  }

  return buf.toString().split('').reversed.join();
}

/// Decodifica una cadena base58btc (sin prefijo `z`) a bytes.
///
/// Lanza [FormatException] si [encoded] contiene caracteres fuera del alfabeto.
Uint8List decodeBase58Btc(String encoded) {
  var leadingZeros = 0;
  for (final ch in encoded.runes) {
    if (String.fromCharCode(ch) != '1') break;
    leadingZeros++;
  }

  var value = BigInt.zero;
  for (final ch in encoded.runes) {
    final idx = _alphabet.indexOf(String.fromCharCode(ch));
    if (idx < 0) {
      throw FormatException('Carácter base58btc inválido: ${String.fromCharCode(ch)}');
    }
    value = value * BigInt.from(58) + BigInt.from(idx);
  }

  final bytes = <int>[];
  while (value > BigInt.zero) {
    bytes.add((value % BigInt.from(256)).toInt());
    value ~/= BigInt.from(256);
  }

  for (var i = 0; i < leadingZeros; i++) {
    bytes.add(0);
  }

  return Uint8List.fromList(bytes.reversed.toList());
}
