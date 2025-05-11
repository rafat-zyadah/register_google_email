import 'package:dartz/dartz.dart';

import '../../../../core/error/failure/failure.dart';
import '../entities/user_entity.dart'; // أضف هذا الاستيراد
import '../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository authRepository;

  VerifyEmailUseCase(this.authRepository);

  Future<Either<Failure, User>> call({ // غيّر نوع الإرجاع إلى User
    required String email,
    required String code,
  }) async {
    return await authRepository.verifyEmail(
      email: email,
      code: code,
    );
  }
}