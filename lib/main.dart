import 'package:flutter/material.dart';
import 'features/auth/data/datasources/google_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'features/auth/domain/usecases/register_user_use_case.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // أضفنا هذا السطر

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoogleAuthDatasource googleAuthService;
  final FlutterSecureStorage secureStorage; // أضفنا هذا السطر
  late final AuthRepositoryImpl authRepositoryImpl;
  late final RegisterUserUseCaseImpl registerUserUseCase;

  MyApp({Key? key})
      : googleAuthService = GoogleAuthDatasource(),
        secureStorage = FlutterSecureStorage(), // هنا أنشأنا كائن جديد من FlutterSecureStorage
        super(key: key) {
    authRepositoryImpl = AuthRepositoryImpl(
      AuthRemoteDataSourceImpl(googleAuthService, secureStorage), // تم تمرير secureStorage بدلاً من googleAuthService
      googleAuthService,
    );

    registerUserUseCase = RegisterUserUseCaseImpl(authRepositoryImpl);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Authentication',
      home: AuthTestScreen(
        authRepositoryImpl: authRepositoryImpl,
        registerUserUseCase: registerUserUseCase,
      ),
    );
  }
}

class AuthTestScreen extends StatelessWidget {
  final AuthRepositoryImpl authRepositoryImpl;
  final RegisterUserUseCaseImpl registerUserUseCase;

  const AuthTestScreen({
    Key? key,
    required this.authRepositoryImpl,
    required this.registerUserUseCase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authentication Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  await authRepositoryImpl.loginWithGoogle();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logged in with Google')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Google login error: $e')),
                  );
                }
              },
              child: Text('Login with Google'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await registerUserUseCase.call(
                    email: 'rafatzyadah@gmail.com',
                    password: 'password1234',
                    name: 'Rafat',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User registered')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Register error: $e')),
                  );
                }
              },
              child: Text('Register with Email'),
            ),
          ],
        ),
      ),
    );
  }
}
