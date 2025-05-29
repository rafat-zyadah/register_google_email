// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_register/features/auth/data/datasources/user_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/google_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_user_use_case.dart';
import 'features/auth/domain/usecases/register_user_use_case.dart';
import 'features/auth/domain/usecases/request_change_email_code_usecase.dart';
import 'features/auth/domain/usecases/verify_change_email_code_usecase.dart';
import 'features/auth/domain/usecases/verify_email_use_case.dart';
import 'features/auth/domain/usecases/change_password_use_case.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoogleAuthDatasource googleAuthService;
  final FlutterSecureStorage secureStorage;
  late final AuthRepositoryImpl authRepositoryImpl;
  late final RegisterUserUseCase registerUserUseCase;
  late final VerifyEmailUseCase verifyEmailUseCase;
  late final LoginUserUseCase loginUserUseCase;
  late final ChangePasswordUseCase changePasswordUseCase;
  late final RequestChangeEmailCodeUseCase requestChangeEmailCodeUseCase;
  late final VerifyChangeEmailCodeUseCase verifyChangeEmailCodeUseCase;

  MyApp({super.key})
      : googleAuthService = GoogleAuthDatasource(),
        secureStorage = const FlutterSecureStorage() {
    final tokenLocalDataSource =
        UserLocalDataSource(secureStorage: secureStorage);
    authRepositoryImpl = AuthRepositoryImpl(
      AuthRemoteDataSourceImpl(googleAuthService),
      tokenLocalDataSource,
      googleAuthService,
    );
    registerUserUseCase = RegisterUserUseCase(authRepositoryImpl);
    verifyEmailUseCase = VerifyEmailUseCase(authRepositoryImpl);
    loginUserUseCase = LoginUserUseCase(authRepositoryImpl);
    changePasswordUseCase = ChangePasswordUseCase(authRepositoryImpl);
    requestChangeEmailCodeUseCase =
        RequestChangeEmailCodeUseCase(authRepositoryImpl);
    verifyChangeEmailCodeUseCase =
        VerifyChangeEmailCodeUseCase(authRepositoryImpl);
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
        changePasswordUseCase: changePasswordUseCase,
        requestChangeEmailCodeUseCase: requestChangeEmailCodeUseCase,
        verifyChangeEmailCodeUseCase: verifyChangeEmailCodeUseCase,
      ),
    );
  }
}

class AuthTestScreen extends StatefulWidget {
  final AuthRepositoryImpl authRepositoryImpl;
  final RegisterUserUseCase registerUserUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final LoginUserUseCase loginUserUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final RequestChangeEmailCodeUseCase requestChangeEmailCodeUseCase;
  final VerifyChangeEmailCodeUseCase verifyChangeEmailCodeUseCase;

  const AuthTestScreen({
    super.key,
    required this.authRepositoryImpl,
    required this.registerUserUseCase,
    required this.verifyEmailUseCase,
    required this.loginUserUseCase,
    required this.changePasswordUseCase,
    required this.requestChangeEmailCodeUseCase,
    required this.verifyChangeEmailCodeUseCase,
  });

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final newEmailController = TextEditingController();
  final newEmailCodeController = TextEditingController();

  void _showDialog(String title, String message) {
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

  Widget _buildInput(String label, TextEditingController controller,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildButton(String label, Future<void> Function() onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🧪 Auth Testing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInput('Email', emailController),
          const SizedBox(height: 8),
          _buildInput('Password', passwordController, obscure: true),
          const SizedBox(height: 8),
          _buildInput('Code', codeController),
          const SizedBox(height: 8),
          _buildInput('New Email', newEmailController),
          const SizedBox(height: 8),
          _buildInput('New Email Code', newEmailCodeController),
          const SizedBox(height: 8),
          _buildInput('New Password', newPasswordController, obscure: true),
          const SizedBox(height: 8),
          _buildInput('Old Password', oldPasswordController, obscure: true),
          const SizedBox(height: 8),
          _buildInput('Confirm New Password', confirmPasswordController,
              obscure: true),
          const SizedBox(height: 20),
          _buildButton('🔐 Login with Google', () async {
            final result = await widget.authRepositoryImpl.signInWithGoogle();
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (_) => _showDialog('نجاح', 'تم تسجيل الدخول بواسطة Google'),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('📝 Register with Email', () async {
            final result = await widget.registerUserUseCase(
              email: emailController.text,
              password: passwordController.text,
            );
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (_) => _showDialog('نجاح', 'تم تسجيل المستخدم بنجاح'),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('✅ Verify Email', () async {
            final result = await widget.verifyEmailUseCase(
              email: emailController.text,
              code: codeController.text,
            );
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (_) => _showDialog('نجاح', 'تم التحقق من البريد الإلكتروني'),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('🔑 Login with Email', () async {
            final result = await widget.loginUserUseCase(
              email: emailController.text,
              password: passwordController.text,
            );
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (user) => _showDialog('نجاح', 'مرحباً ${user.email}'),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('🚪 Logout', () async {
            final result = await widget.authRepositoryImpl.logout();
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (_) => _showDialog('نجاح', 'تم تسجيل الخروج'),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('📤 Send Reset Code', () async {
            final result = await widget.authRepositoryImpl
                .sendResetCodeToEmail(emailController.text);
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (_) => _showDialog('نجاح', 'تم إرسال كود التعيين'),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('🔄 Verify Reset Code', () async {
            final result = await widget.authRepositoryImpl.verifyResetCode(
              emailController.text,
              codeController.text,
              newPasswordController.text,
            );
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (_) => _showDialog('نجاح', 'تم تغيير كلمة المرور'),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('🛡 Change Password', () async {
            final result = await widget.changePasswordUseCase(
              oldPassword: oldPasswordController.text,
              newPassword: newPasswordController.text,
              confirmPassword: confirmPasswordController.text,
            );
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (_) => _showDialog('نجاح', 'تم تغيير كلمة المرور بنجاح'),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('📦 Load Token', () async {
            final result = await widget.authRepositoryImpl.loadToken();
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (token) => _showDialog('Token', token!),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('👤 Load User', () async {
            final result = await widget.authRepositoryImpl.loadUser();
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (user) => _showDialog('User', user.email),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('📧 Request Change Email Code', () async {
            final result = await widget.requestChangeEmailCodeUseCase();
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (_) => _showDialog('نجاح', 'تم إرسال كود للإيميل الحالي للتحقق'),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('🔓 Verify Current Email Code & Send Code to New Email',
              () async {
            final result = await widget.verifyChangeEmailCodeUseCase(
              code: codeController.text,
              newEmail: newEmailController.text,
            );
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (_) => _showDialog('نجاح', 'تم إرسال كود للإيميل الجديد'),
            );
          }),
          const SizedBox(height: 12),
          _buildButton('✅ Verify New Email', () async {
            final result = await widget.verifyEmailUseCase(
              email: newEmailController.text,
              code: newEmailCodeController.text,
            );
            result.fold(
              (f) => _showDialog('خطأ', f.message),
              (_) => _showDialog('نجاح', 'تم التحقق من الإيميل الجديد'),
            );
          }),
        ],
      ),
    );
  }
}
