import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions/auth_exception.dart';
import '../../../../core/errors/exceptions/cache_exception.dart';
import '../../../../core/errors/exceptions/network_exception.dart';
import '../../../../core/errors/exceptions/server_exception.dart';
import '../../../../core/errors/failures/app_failure.dart';
import '../../../../core/errors/failures/auth_failure.dart';
import '../../../../core/errors/failures/cache_failure.dart';
import '../../../../core/errors/failures/network_failure.dart';
import '../../../../core/errors/failures/server_failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/validators/password_validator.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/google_auth_datasource.dart';
import '../datasources/user_local_data_source.dart';
import '../models/user_model.dart';
import '../../domain/validators/email_validator.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final GoogleAuthDatasource googleAuth;

  AuthRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.googleAuth,
  );
  @override
  Future<Either<AppFailure, Unit>> registerUser({
    required String email,
    required String password,
  }) async {
    if (!EmailValidator.isValid(email)) {
      return Left(AuthFailure("Invalid email format"));
    }
    if (!PasswordValidator.isValid(password)) {
      return Left(AuthFailure("Password must be at least 8 characters"));
    }

    return await _handleErrors<Unit>(() async {
      await remoteDataSource.registerUser(
        email: email,
        password: password,
      );
      return unit;
    });
  }

  @override
  Future<Either<AppFailure, User>> signInWithGoogle() async {
    return await _handleErrors<User>(() async {
      final userModel = await remoteDataSource.loginWithGoogle();
      await _saveTokenIfPresent(userModel.token);
      await localDataSource.cacheUser(userModel);
      return userModel.toEntity();
    });
  }

  @override
  Future<Either<AppFailure, Unit>> verifyEmail({
    required String email,
    required String code,
  }) async {
    return await _handleErrors<Unit>(() async {
      await remoteDataSource.verifyEmail(
        email: email,
        code: code,
      );
      return unit;
    });
  }

  @override
  Future<Either<AppFailure, User>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (!EmailValidator.isValid(email)) {
      return Left(AuthFailure("Invalid email format"));
    }
    return await _handleErrors<User>(() async {
      final userModel = await remoteDataSource.loginWithEmail(
        email: email,
        password: password,
      );
      await _saveTokenIfPresent(userModel.token);
      await localDataSource.cacheUser(userModel);
      return userModel.toEntity();
    });
  }

  @override
  Future<Either<AppFailure, Unit>> logout() async {
    final tokenResult = await localDataSource.loadToken();

    return await tokenResult.fold(
      (failure) async => Left(failure),
      (token) async {
        if (token == null) {
          return Left(CacheFailure("No token found"));
        }

        return await _handleErrors<Unit>(() async {
          await remoteDataSource.logout(token);

          final userResult = await localDataSource.loadUser();

          await userResult.fold(
            (failure) async {},
            (user) async {
              if (user?.authType == 'google') {
                await googleAuth.signOut();
              }
            },
          );

          await localDataSource.clearSession();

          return unit;
        });
      },
    );
  }

  @override
  Future<Either<AppFailure, Unit>> sendResetCodeToEmail(String email) async {
    if (!EmailValidator.isValid(email)) {
      return Left(AuthFailure("Invalid email format"));
    }
    return await _handleErrors<Unit>(() async {
      await remoteDataSource.sendResetCodeToEmail(email);
      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> verifyResetCode(
      String email, String code, String newPassword) async {
    if (!EmailValidator.isValid(email)) {
      return Left(AuthFailure("Invalid email format"));
    }
    if (code.length != 4) {
      return Left(AuthFailure("Invalid reset code"));
    }
    if (!PasswordValidator.isValid(newPassword)) {
      return Left(AuthFailure("Password must be at least 8 characters"));
    }

    return await _handleErrors<Unit>(() async {
      await remoteDataSource.verifyResetCode(email, code, newPassword);
      return unit;
    });
  }

  @override
  Future<Either<AppFailure, String?>> loadToken() async {
    return await localDataSource.loadToken();
  }

  @override
  Future<Either<AppFailure, User>> loadUser() async {
    final result = await localDataSource.loadUser();
    return result.fold(
      (failure) => Left(failure),
      (userModel) {
        if (userModel == null) return Left(CacheFailure('No user stored'));
        return Right(userModel.toEntity());
      },
    );
  }

  @override
  Future<Either<AppFailure, Unit>> requestChangeEmailCode() async {
    final tokenResult = await localDataSource.loadToken();

    return await tokenResult.fold(
      (failure) async => Left(failure),
      (token) async {
        if (token == null) {
          return Left(CacheFailure("No token found"));
        }

        return await _handleErrors<Unit>(() async {
          await remoteDataSource.requestChangeEmailCode(token);
          return unit;
        });
      },
    );
  }

  @override
  Future<Either<AppFailure, Unit>> verifyChangeEmailCode({
    required String code,
    required String newEmail,
  }) async {
    if (!EmailValidator.isValid(newEmail)) {
      return Left(AuthFailure("Invalid email format"));
    }
    if (code.length != 4) {
      return Left(AuthFailure("Invalid verification code"));
    }

    final tokenResult = await localDataSource.loadToken();

    return await tokenResult.fold(
      (failure) async => Left(failure),
      (token) async {
        if (token == null) {
          return Left(CacheFailure("No token found"));
        }

        return await _handleErrors<Unit>(() async {
          await remoteDataSource.verifyChangeEmailCode(
            code: code,
            newEmail: newEmail,
            token: token,
          );

          final localUserResult = await localDataSource.loadUser();
          await localUserResult.fold(
            (failure) async {},
            (user) async {
              if (user != null) {
                final updatedUser = UserModel(
                  id: user.id,
                  email: newEmail,
                  authType: user.authType,
                  token: user.token,
                );

                await localDataSource.cacheUser(updatedUser);
              }
            },
          );

          return unit;
        });
      },
    );
  }

  @override
  Future<Either<AppFailure, Unit>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!PasswordValidator.isValid(newPassword)) {
      return Left(AuthFailure("Password must be at least 8 characters"));
    }

    final tokenResult = await localDataSource.loadToken();

    return await tokenResult.fold(
      (failure) async => Left(failure),
      (token) async {
        if (token == null) {
          return Left(CacheFailure("No token found"));
        }

        return await _handleErrors<Unit>(() async {
          await remoteDataSource.changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
            token: token,
          );
          return unit;
        });
      },
    );
  }

  Future<Either<AppFailure, T>> _handleErrors<T>(
      Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _saveTokenIfPresent(String? token) async {
    if (token != null && token.isNotEmpty) {
      await localDataSource.cacheToken(token);
    }
  }
}

extension UserModelMapper on UserModel {
  User toEntity() {
    return User(
      id: this.id,
      email: email,
      authType: authType,
    );
  }
}
