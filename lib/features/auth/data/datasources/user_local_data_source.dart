import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/failures/app_failure.dart';
import '../../../../core/errors/failures/cache_failure.dart';
import '../models/user_model.dart';

const _kUserKey = 'CACHED_USER';
const _kTokenKey = 'CACHED_TOKEN';

class UserLocalDataSource {
  final FlutterSecureStorage secureStorage;

  UserLocalDataSource({required this.secureStorage});

  Future<Either<AppFailure, Unit>> cacheUser(UserModel user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await secureStorage.write(key: _kUserKey, value: jsonString);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to store user data: $e'));
    }
  }

  Future<Either<AppFailure, UserModel?>> loadUser() async {
    try {
      final jsonString = await secureStorage.read(key: _kUserKey);
      if (jsonString == null) return const Right(null);
      final Map<String, dynamic> map = jsonDecode(jsonString);
      final user = UserModel.fromJson(map, authType: map['authType'] as String);
      return Right(user);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch user data: $e'));
    }
  }

  Future<Either<AppFailure, Unit>> cacheToken(String token) async {
    try {
      await secureStorage.write(key: _kTokenKey, value: token);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to store token: $e'));
    }
  }

  Future<Either<AppFailure, String?>> loadToken() async {
    try {
      final token = await secureStorage.read(key: _kTokenKey);
      return Right(token);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch token: $e'));
    }
  }

  Future<Either<AppFailure, Unit>> clearSession() async {
    try {
      await secureStorage.delete(key: _kUserKey);
      await secureStorage.delete(key: _kTokenKey);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete user data: $e'));
    }
  }
}
