import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures/app_failure.dart';
import '../repositories/auth_repository.dart';

class VerifyChangeEmailCodeUseCase {
  final AuthRepository repository;

  VerifyChangeEmailCodeUseCase(this.repository);

  Future<Either<AppFailure, Unit>> call({
    required String code,
    required String newEmail,
  }) async {
    return repository.verifyChangeEmailCode(
      code: code,
      newEmail: newEmail,
    );
  }
}
