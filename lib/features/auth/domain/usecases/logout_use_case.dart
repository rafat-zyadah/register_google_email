
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures/app_failure.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<Either<AppFailure, Unit>> call() async {
    return await repository.logout();
  }
}