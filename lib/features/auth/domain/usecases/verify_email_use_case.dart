import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures/app_failure.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository authRepository;

  VerifyEmailUseCase(this.authRepository);

  Future<Either<AppFailure, Unit>> call({
    required String email,
    required String code,
  }) async {
    return await authRepository.verifyEmail(
      email: email,
      code: code,
    );
  }
}
