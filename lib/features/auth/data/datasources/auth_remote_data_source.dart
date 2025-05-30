import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions/auth_exception.dart';
import '../../../../core/errors/exceptions/network_exception.dart';
import '../../../../core/errors/exceptions/server_exception.dart';
import '../../../../core/util/api-endpoints/api_endpoints.dart';
import '../models/user_model.dart';
import 'google_auth_datasource.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> registerUser({
    required String email,
    required String password,
  });

  Future<UserModel> loginWithGoogle();

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<String> verifyEmail({
    required String email,
    required String code,
  });

  Future<void> logout(String token);

  Future<void> sendResetCodeToEmail(String email);

  Future<void> verifyResetCode(String email, String code, String newPassword);

  //change password by enter current password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String token,
  });

  
  Future<void> requestChangeEmailCode(String token);
  Future<void> verifyChangeEmailCode({
    required String code,
    required String newEmail,
    required String token,
  });

}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleAuthDatasource googleAuthDatasource;

  AuthRemoteDataSourceImpl(this.googleAuthDatasource);

  Future<Map<String, dynamic>> _post(
    String url,
    Map payload, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        body: jsonEncode(payload),
      );

      debugPrint(
        "Response from $url: ${response.body} (status: ${response.statusCode})",
      );

      final Map<String, dynamic> data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      final message = data['message'] as String? ?? 'Request failed';
      throw ServerException(message);
    } on SocketException {
      throw NetworkException("No internet connection");
    } on FormatException {
      throw ServerException("Invalid JSON format in response");
    }
  }

  @override
  Future<void> sendResetCodeToEmail(String email) async {
    await _post(ApiEndpoints.requestResetCode, {
      'email': email,
    });
  }

  @override
  Future<void> verifyResetCode(
    String email,
    String code,
    String newPassword,
  ) async {
    await _post(ApiEndpoints.verifyResetCode, {
      'email': email,
      'code': code,
      'password': newPassword,
    });
  }

  @override
  Future<void> logout(String token) async {
    await _post(
      ApiEndpoints.logout,
      {},
      headers: {'Authorization': 'Bearer $token'},
    );
  }


  @override
  Future<void> requestChangeEmailCode(String token) async {
    await _post(
      ApiEndpoints.requestChangeEmailCode,
      {},
      headers: {'Authorization': 'Bearer $token'},
    );
  }
  

  @override
  Future<void> verifyChangeEmailCode({
    required String code,
    required String newEmail,
    required String token,
  }) async {
    await _post(
      ApiEndpoints.verifyChangeEmailCode,
      {
        'code': code,
        'new_email': newEmail,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
  }

@override
Future<void> changePassword({
  required String oldPassword,
  required String newPassword,
  required String token,
}) async {
  await _post(
    ApiEndpoints.changePassword,
    {
      'current_password': oldPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPassword, 
    },
    headers: {'Authorization': 'Bearer $token'},
  );
}

  @override
  Future<UserModel> registerUser({
    required String email,
    required String password,
  }) async {
    final jsonData = await _post(ApiEndpoints.register, {
      'email': email,
      'password': password,
    });

    return UserModel.fromJson(jsonData['user'], authType: 'email');
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    final idToken = await googleAuthDatasource.signInAndGetIdToken();
    if (idToken == null) throw AuthException("Google Sign-In failed");

    final jsonData = await _post(ApiEndpoints.googleLogin, {
      'id_token': idToken,
    });

    return UserModel.fromJson(
      {
        ...jsonData['user'],
        'token': jsonData['token'],
      },
      authType: 'google',
    );
  }

  @override
  Future<String> verifyEmail({
    required String email,
    required String code,
  }) async {
    final jsonData = await _post(ApiEndpoints.verifyCode, {
      'email': email,
      'code': code,
    });

    if (jsonData.containsKey('message')) {
      return jsonData['message'] as String;
    } else {
      throw ServerException('Unexpected response format from server');
    }
  }

  @override
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final jsonData = await _post(ApiEndpoints.login, {
      'email': email,
      'password': password,
    });

    return UserModel.fromJson(
      {
        ...jsonData['user'],
        'token': jsonData['token'],
      },
      authType: 'email',
    );
  }
}
