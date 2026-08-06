import 'package:freezed_annotation/freezed_annotation.dart';

part 'didcomm_message.freezed.dart';
part 'didcomm_message.g.dart';

/// Mensaje DIDComm v2.
///
/// Representa el payload descifrado de un mensaje DIDComm. Los campos siguen
/// la especificación DIDComm Messaging v2.0.
@freezed
class DidCommMessage with _$DidCommMessage {
  const factory DidCommMessage({
    required String id,
    required String type,
    String? from,
    List<String>? to,
    @JsonKey(name: 'created_time') int? createdTime,
    @JsonKey(name: 'expires_time') int? expiresTime,
    Map<String, dynamic>? body,
    @JsonKey(name: '~attach') List<Map<String, dynamic>>? attachments,
  }) = _DidCommMessage;

  factory DidCommMessage.fromJson(Map<String, dynamic> json) =>
      _$DidCommMessageFromJson(json);
}
