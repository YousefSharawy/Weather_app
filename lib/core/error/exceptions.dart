class CustomException implements Exception {
  final String message;
  CustomException(this.message);
}

class RemoteException extends CustomException {
  RemoteException(super.message);
}
