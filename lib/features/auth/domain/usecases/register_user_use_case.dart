import 'package:dartz/dartz.dart';

import '../../../../core/error/failure/failure.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<Either<Failure, Unit>> call({ // تم تغيير نوع الإرجاع إلى Unit
    required String name,
    required String email,
    required String password,
  }) async {
    return repository.registerUser(
      name: name,
      email: email,
      password: password,
    );
  }
}