
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

abstract class RegisterUserUseCase {
  Future<User> call({
    required String name,
    required String email,
    required String password,
  });
}

class RegisterUserUseCaseImpl implements RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCaseImpl(this.repository);

  @override
  Future<User> call({
    required String name,
    required String email,
    required String password,
  }) async {
    return await repository.registerUser(
      name: name,
      email: email,
      password: password,
    );
  }
}
