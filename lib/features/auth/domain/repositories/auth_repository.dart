import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
  });

  Future<void> loginWithGoogle();

  // إضافة الدالة الخاصة بالتحقق من البريد الإلكتروني
  Future<void> verifyEmail({
    required String email,
    required String code,
  });
}
