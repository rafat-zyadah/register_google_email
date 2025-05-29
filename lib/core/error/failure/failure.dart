
export 'auth_failure.dart';
export 'network_failure.dart';
export 'server_failure.dart';
export 'cache_failure.dart';
export 'failure.dart';
abstract class Failure {
  final String message;
  Failure(this.message);
}

