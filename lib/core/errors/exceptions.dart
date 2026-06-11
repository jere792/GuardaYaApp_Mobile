class ServerException implements Exception {
  final String message;
  ServerException({this.message = 'Error del servidor'});
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException({this.message = 'Error de cache local'});
  @override
  String toString() => 'CacheException: $message';
}

class NoInternetException implements Exception {
  final String message;
  NoInternetException({this.message = 'No hay conexion a internet'});
  @override
  String toString() => 'NoInternetException: $message';
}

class AuthException implements Exception {
  final String message;
  AuthException({this.message = 'Error de autenticacion'});
  @override
  String toString() => 'AuthException: $message';
}

class OcrException implements Exception {
  final String message;
  OcrException({this.message = 'Error al procesar OCR'});
  @override
  String toString() => 'OcrException: $message';
}
