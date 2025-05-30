import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures/app_failure.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<Either<AppFailure, Unit>> call({ 
    required String email,
    required String password,
  }) async {
    return repository.registerUser(
      email: email,
      password: password,
    );
  }
}