// domain/usecases/login_with_email_use_case.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUserUseCase {
  final AuthRepository repository;

  LoginUserUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) {
    return repository.loginWithEmail(email: email, password: password);
  }
}
