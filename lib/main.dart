// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/error/failure/failure.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/google_auth_datasource.dart';
import 'features/auth/data/datasources/token_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_user_use_case.dart';
import 'features/auth/domain/usecases/register_user_use_case.dart';
import 'features/auth/domain/usecases/verify_email_use_case.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // تحميل المتغيرات البيئية
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoogleAuthDatasource googleAuthService;
  final FlutterSecureStorage secureStorage;
  late final AuthRepositoryImpl authRepositoryImpl;
  late final RegisterUserUseCase registerUserUseCase;
  late final VerifyEmailUseCase verifyEmailUseCase;
  late final LoginUserUseCase loginUserUseCase;

  MyApp({super.key})
      : googleAuthService = GoogleAuthDatasource(),
        secureStorage = const FlutterSecureStorage() {
    final tokenLocalDataSource = TokenLocalDataSource(secureStorage);
    authRepositoryImpl = AuthRepositoryImpl(
      AuthRemoteDataSourceImpl(googleAuthService),
      tokenLocalDataSource,
    );

    registerUserUseCase = RegisterUserUseCase(authRepositoryImpl);
    verifyEmailUseCase = VerifyEmailUseCase(authRepositoryImpl);
    loginUserUseCase = LoginUserUseCase(authRepositoryImpl);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Authentication',
      theme: ThemeData(useMaterial3: true),
      home: AuthTestScreen(
        authRepositoryImpl: authRepositoryImpl,
        registerUserUseCase: registerUserUseCase,
        verifyEmailUseCase: verifyEmailUseCase,
        loginUserUseCase: loginUserUseCase,
      ),
    );
  }
}

class AuthTestScreen extends StatelessWidget {
  final AuthRepositoryImpl authRepositoryImpl;
  final RegisterUserUseCase registerUserUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final LoginUserUseCase loginUserUseCase;

  const AuthTestScreen({
    super.key,
    required this.authRepositoryImpl,
    required this.registerUserUseCase,
    required this.verifyEmailUseCase,
    required this.loginUserUseCase,
  });

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const email = 'rafatzyadah@gmail.com';
    const password = 'password1234';

    return Scaffold(
      appBar: AppBar(title: const Text('Authentication Test')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  await authRepositoryImpl.signInWithGoogle();
                  _showDialog(context, 'نجاح', 'تم تسجيل الدخول بواسطة Google');
                } catch (e) {
                  _showDialog(context, 'خطأ', 'فشل تسجيل الدخول: $e');
                }
              },
              child: const Text('Login with Google'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await registerUserUseCase.call(
                    name: 'Rafat',
                    email: email,
                    password: password,
                  );
                  _showDialog(context, 'نجاح', 'تم تسجيل المستخدم بنجاح');
                } catch (e) {
                  _showDialog(context, 'خطأ', 'فشل التسجيل: $e');
                }
              },
              child: const Text('Register with Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await verifyEmailUseCase.call(
                    email: email,
                    code: '7819',
                  );
                  _showDialog(
                      context, 'نجاح', 'تم التحقق من البريد الإلكتروني');
                } catch (e) {
                  _showDialog(context, 'خطأ', 'فشل التحقق: $e');
                }
              },
              child: const Text('Verify Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await loginUserUseCase.call(
                  email: email,
                  password: password,
                );

                result.fold(
                  (Failure failure) => _showDialog(
                      context, 'خطأ', 'فشل تسجيل الدخول: ${failure.message}'),
                  (user) => _showDialog(
                      context, 'نجاح', 'تم تسجيل الدخول: ${user.name}'),
                );
              },
              child: const Text('Login with Email'),
            ),
          ],
        ),
      ),
    );
  }
}
