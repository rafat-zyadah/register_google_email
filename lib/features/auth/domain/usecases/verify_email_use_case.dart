import '../repositories/auth_repository.dart';

// تعريف الواجهة
abstract class VerifyEmailUseCase {
  Future<void> call({required String email, required String code});
}

// تطبيق الـ UseCase
class VerifyEmailUseCaseImpl implements VerifyEmailUseCase {
  final AuthRepository authRepository;

  VerifyEmailUseCaseImpl(this.authRepository);

  @override
  Future<void> call({required String email, required String code}) async {
    await authRepository.verifyEmail(
        email: email, code: code); // استدعاء الدالة في الـ Repository
  }
}
