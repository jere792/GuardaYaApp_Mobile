abstract class Failure {
  final String message;
  Failure(this.message);
  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

class NoInternetFailure extends Failure {
  NoInternetFailure() : super('No hay conexion a internet');
}

class AuthFailure extends Failure {
  AuthFailure(String message) : super(message);
}

class OcrFailure extends Failure {
  OcrFailure(String message) : super(message);
}
