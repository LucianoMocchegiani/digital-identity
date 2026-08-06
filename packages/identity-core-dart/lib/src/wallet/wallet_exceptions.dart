/// Excepciones del ciclo de vida del wallet cifrado.
library;

/// Error lanzado al intentar acceder a los stores de un wallet bloqueado.
class WalletLockedError implements Exception {
  const WalletLockedError();

  @override
  String toString() => 'WalletLockedError: el wallet está bloqueado.';
}

/// Error lanzado cuando el PIN no coincide con el wallet al intentar desbloquearlo.
class WrongPinError implements Exception {
  const WrongPinError();

  @override
  String toString() => 'WrongPinError: PIN incorrecto.';
}

/// Error lanzado al intentar abrir un wallet que no fue creado aún.
class WalletNotFoundError implements Exception {
  const WalletNotFoundError(this.walletId);

  final String walletId;

  @override
  String toString() => 'WalletNotFoundError: wallet "$walletId" no encontrado.';
}

/// Error lanzado al intentar crear un wallet cuyo salt ya existe en secure storage.
class WalletAlreadyExistsError implements Exception {
  const WalletAlreadyExistsError(this.walletId);

  final String walletId;

  @override
  String toString() =>
      'WalletAlreadyExistsError: wallet "$walletId" ya existe.';
}
