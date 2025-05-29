import 'package:dartz/dartz.dart';
import '../../../../core/error/failure/failure.dart';
import '../repositories/auth_repository.dart';

class VerifyChangeEmailCodeUseCase {
  final AuthRepository repository;

  VerifyChangeEmailCodeUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String code,
    required String newEmail,
  }) async {
    return repository.verifyChangeEmailCode(
      code: code,
      newEmail: newEmail,
    );
  }
}
