import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions/exceptions.dart';
import '../../../../core/utils/api_endpoints.dart';
import '../models/user_model.dart';
import 'google_auth_datasource.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> loginWithGoogle();

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> verifyEmail({
    required String email,
    required String code,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleAuthDatasource googleAuthDatasource;

  AuthRemoteDataSourceImpl(this.googleAuthDatasource);

  Future<Map<String, dynamic>> _post(String url, Map payload) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint("Response from $url: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw ServerException(errorData['message'] ?? 'Request failed');
      }
    } on SocketException {
      throw NetworkException("No internet connection");
    } on FormatException {
      throw ServerException("Invalid response format");
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final jsonData = await _post(ApiEndpoints.register, {
      'name': name,
      'email': email,
      'password': password,
    });

    return UserModel.fromJson(jsonData['user']);
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      final idToken = await googleAuthDatasource.signInAndGetIdToken();
      if (idToken == null) throw AuthException("Google Sign-In failed");

      final jsonData = await _post(ApiEndpoints.googleLogin, {
        'id_token': idToken,
      });

      return UserModel.fromJson({
        ...jsonData['user'],
        'token': jsonData['token'],
      });
    } on SocketException {
      throw NetworkException("No internet connection");
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyEmail({
    required String email,
    required String code,
  }) async {
    final jsonData = await _post(ApiEndpoints.verifyCode, {
      'email': email,
      'code': code,
    });

    return UserModel.fromJson({
      ...jsonData['user'],
      'token': jsonData['token'],
    });
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

    return UserModel.fromJson({
      ...jsonData['user'],
      'token': jsonData['token'],
    });
  }
}
