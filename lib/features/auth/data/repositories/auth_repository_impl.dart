import 'package:google_register/features/auth/data/datasources/auth_remote_data_source_interface.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final IAuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.registerUser(name:name, email:email, password:password);
  }

  @override
  Future<void> loginWithGoogle() async {
    return await remoteDataSource.loginWithGoogle();
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    // استدعاء دالة التحقق من البريد الإلكتروني في DataSource
    await remoteDataSource.verifyEmail(email:email, code:code);
  }
}
