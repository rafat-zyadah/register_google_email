// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'features/auth/data/datasources/google_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'features/auth/domain/usecases/register_user_use_case.dart';
import 'features/auth/domain/usecases/verify_email_use_case.dart'; // أضفنا هذا السطر
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoogleAuthDatasource googleAuthService;
  final FlutterSecureStorage secureStorage;
  late final AuthRepositoryImpl authRepositoryImpl;
  late final RegisterUserUseCaseImpl registerUserUseCase;
  late final VerifyEmailUseCaseImpl verifyEmailUseCase; // أضفنا هذا السطر

  MyApp({super.key})
      : googleAuthService = GoogleAuthDatasource(),
        secureStorage = const FlutterSecureStorage() {
    authRepositoryImpl = AuthRepositoryImpl(
      AuthRemoteDataSourceImpl(googleAuthService, secureStorage),
    );

    registerUserUseCase = RegisterUserUseCaseImpl(authRepositoryImpl);
    verifyEmailUseCase = VerifyEmailUseCaseImpl(
        authRepositoryImpl); // تم تهيئة الـ UseCase الخاص بالتحقق من الإيميل
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Authentication',
      home: AuthTestScreen(
        authRepositoryImpl: authRepositoryImpl,
        registerUserUseCase: registerUserUseCase,
        verifyEmailUseCase: verifyEmailUseCase, // تم تمرير الـ UseCase هنا
      ),
    );
  }
}

class AuthTestScreen extends StatelessWidget {
  final AuthRepositoryImpl authRepositoryImpl;
  final RegisterUserUseCaseImpl registerUserUseCase;
  final VerifyEmailUseCaseImpl verifyEmailUseCase; // تم إضافة هذا السطر

  const AuthTestScreen({
    super.key,
    required this.authRepositoryImpl,
    required this.registerUserUseCase,
    required this.verifyEmailUseCase, // تم إضافة هذا السطر
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  await authRepositoryImpl.loginWithGoogle();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged in with Google')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Google login error: $e')),
                  );
                }
              },
              child: const Text('Login with Google'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await registerUserUseCase.call(
                    email: 'rafatzyadah@gmail.com',
                    password: 'password1234',
                    name: 'Rafat',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User registered')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Register error: $e')),
                  );
                }
              },
              child: const Text('Register with Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // مثال على التحقق من الكود بعد التسجيل
                try {
                  await verifyEmailUseCase.call(
                    email: 'rafatzyadah@gmail.com',
                    code: '4730', // هنا ضع الكود الذي سيتم التحقق منه
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Email verified and token stored')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Verification error: $e')),
                  );
                }
              },
              child: const Text('Verify Email'),
            ),
          ],
        ),
      ),
    );
  }
}
