import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions/exceptions.dart';
import '../../../../core/error/failure/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/token_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenLocalDataSource tokenLocalDataSource;

  AuthRepositoryImpl(
    this.remoteDataSource,
    this.tokenLocalDataSource,
  );

  @override
  Future<Either<Failure, Unit>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _handleErrors<Unit>(() async {
      await remoteDataSource.registerUser(
        name: name,
        email: email,
        password: password,
      );
      return unit;
    });
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    return await _handleErrors<User>(() async {
      final userModel = await remoteDataSource.loginWithGoogle();
      await _saveTokenIfPresent(userModel.token);
      return userModel.toEntity();
    });
  }

  @override
  Future<Either<Failure, User>> verifyEmail({
    required String email,
    required String code,
  }) async {
    return await _handleErrors<User>(() async {
      final userModel = await remoteDataSource.verifyEmail(
        email: email,
        code: code,
      );
      await _saveTokenIfPresent(userModel.token);
      return userModel.toEntity();
    });
  }





  Future<void> _saveTokenIfPresent(String? token) async {
    if (token != null && token.isNotEmpty) {
      await tokenLocalDataSource.cacheToken(token);
    }
  }

@override
Future<Either<Failure, User>> loginWithEmail({
  required String email,
  required String password,
}) async {
  return await _handleErrors<User>(() async {
    final userModel = await remoteDataSource.loginWithEmail(
      email: email,
      password: password,
    );
    await _saveTokenIfPresent(userModel.token);
    return userModel.toEntity();
  });
}



  Future<Either<Failure, T>> _handleErrors<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }




}

extension UserModelMapper on UserModel {
  User toEntity() {
    return User(
      id:this.id,
      name: name,
      email: email,
    );
  }
}