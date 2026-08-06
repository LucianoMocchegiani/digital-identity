/// Tipo de invitación detectada en un QR / deeplink / clipboard.
enum InvitationType {
  /// Oferta de credencial vía OID4VCI.
  openid4vciOffer,

  /// Solicitud de presentación vía OID4VP.
  openid4vpRequest,

  /// Invitación DIDComm (OOB, connectionless, etc.).
  didcommInvitation,
}
