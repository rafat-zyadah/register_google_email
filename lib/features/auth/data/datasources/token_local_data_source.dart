import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/failure/failure.dart'; // تأكد من المسار الصحيح

class TokenLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const _tokenKey = 'auth_token';

  TokenLocalDataSource(this.secureStorage);

  Future<Either<Failure, Unit>> cacheToken(String token) async {
    try {
      await secureStorage.write(key: _tokenKey, value: token);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to cache token: $e'));
    }
  }

  Future<Either<Failure, Unit>> deleteToken() async {
    try {
      await secureStorage.delete(key: _tokenKey);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete token: $e'));
    }
  }

  Future<Either<Failure, String>> getToken() async {
    try {
      final token = await secureStorage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        return Left(CacheFailure('No token found'));
      }
      return Right(token);
    } catch (e) {
      return Left(CacheFailure('Failed to read token: $e'));
    }
  }

  Future<Either<Failure, bool>> hasToken() async {
    final result = await getToken();
    return result.fold(
      (failure) => const Right(false),
      (token) => Right(token.isNotEmpty),
    );
  }
}
