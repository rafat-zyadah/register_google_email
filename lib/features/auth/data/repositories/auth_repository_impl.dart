
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source_interface.dart';
import '../datasources/google_auth_datasource.dart';
import '../../domain/entities/user_entity.dart';
class AuthRepositoryImpl implements AuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final GoogleAuthDatasource googleAuthService;

  AuthRepositoryImpl(this.remoteDataSource, this.googleAuthService);

  @override
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.registerUser(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> loginWithGoogle() async {
    return await remoteDataSource.loginWithGoogle();
  }
}
