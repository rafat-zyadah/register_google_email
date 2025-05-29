export  'auth_exception.dart';
export  'network_exception.dart';
export  'server_exception.dart';
export  'app_exception.dart';
export  'cache_exception.dart';

abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}
