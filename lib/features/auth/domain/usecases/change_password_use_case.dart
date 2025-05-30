import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures/app_failure.dart';
import '../../../../core/errors/failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<AppFailure, Unit>> call({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      return Left(AuthFailure("New password and confirmation do not match"));
    }

    return repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
