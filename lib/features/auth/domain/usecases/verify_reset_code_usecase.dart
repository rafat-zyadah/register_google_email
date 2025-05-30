import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures/app_failure.dart';
import '../repositories/auth_repository.dart';
//Used to verify password reset code
class VerifyResetCodeUseCase {
  final AuthRepository repository;
  VerifyResetCodeUseCase(this.repository);

  Future<Either<AppFailure, Unit>> call(String email, String code, String newPassword) async {
    return await repository.verifyResetCode(email, code, newPassword);
  }
}