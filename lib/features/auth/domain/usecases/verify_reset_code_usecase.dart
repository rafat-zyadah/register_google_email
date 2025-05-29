import 'package:dartz/dartz.dart';
import '../../../../core/error/failure/failure.dart';
import '../repositories/auth_repository.dart';
//Used to verify password reset code
class VerifyResetCodeUseCase {
  final AuthRepository repository;
  VerifyResetCodeUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String email, String code, String newPassword) async {
    return await repository.verifyResetCode(email, code, newPassword);
  }
}