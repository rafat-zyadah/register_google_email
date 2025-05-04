import '../../domain/entities/user_entity.dart';

abstract class IAuthRemoteDataSource {
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
  });

  Future<void> loginWithGoogle();
}
