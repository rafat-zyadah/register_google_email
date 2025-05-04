import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // لتخزين الـ token بشكل آمن
import '../../../../core/utils/api_endpoints.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_remote_data_source_interface.dart';
import 'google_auth_datasource.dart';

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final GoogleAuthDatasource googleAuthDatasource;
  final FlutterSecureStorage secureStorage; // لتخزين الـ token بشكل آمن

  AuthRemoteDataSourceImpl(this.googleAuthDatasource, this.secureStorage);

  @override
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.register),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    print("Register response body: ${response.body}"); // طباعة response body

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final token = jsonData['token']; // الحصول على الـ token

      // تخزين الـ token بشكل آمن
      await secureStorage.write(key: 'token', value: token);

      return User(
        id: jsonData['user']['id'],
        name: jsonData['user']['name'],
        email: jsonData['user']['email'],
        verificationCode: jsonData['user']['verification_code'],
      );
    } else if (response.statusCode == 400) {
      final jsonData = jsonDecode(response.body);
      throw Exception(jsonData['message'] ?? 'Registration failed');
    } else {
      throw Exception('Registration failed');
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    final idToken = await googleAuthDatasource.signInAndGetIdToken();
    if (idToken == null) throw Exception("Google Sign-In failed");

    final response = await http.post(
      Uri.parse(ApiEndpoints.googleLogin),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'id_token': idToken}),
    );

    print("Login response body: ${response.body}"); // طباعة response body

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final token = jsonData['token'];

      // تخزين الـ token بشكل آمن
      await secureStorage.write(key: 'token', value: token);

      print('Login successful: ${response.body}');
    } else {
      throw Exception('Failed to authenticate with backend');
    }
  }

  // إضافة وظيفة للتحقق من الكود المرسل عبر البريد الإلكتروني
  Future<void> verifyEmail(String email, String code) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.verifyCode), // تعديل المسار هنا
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'code': code,
      }),
    );

    print(
        "Verify email response body: ${response.body}"); // طباعة response body

    if (response.statusCode == 200) {
      print('Email verified successfully');
    } else {
      final jsonData = jsonDecode(response.body);
      throw Exception(jsonData['message'] ?? 'Email verification failed');
    }
  }

  // وظيفة تسجيل الخروج
  Future<void> logout() async {
    await secureStorage.delete(key: 'token');
    print('Logged out successfully');
  }
}
