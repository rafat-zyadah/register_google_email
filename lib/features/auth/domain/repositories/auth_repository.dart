import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures/app_failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {

  Future<Either<AppFailure,Unit >> registerUser({
    required String email,
    required String password,
  });
/*========================================================*/


  Future<Either<AppFailure, Unit>> verifyEmail({
    required String email,
    required String code,
  });
/*========================================================*/
  Future<Either<AppFailure, User>> signInWithGoogle();
/*========================================================*/
  Future<Either<AppFailure, User>> loginWithEmail({
    required String email,
    required String password,
  });
/*========================================================*/
Future<Either<AppFailure, Unit>> logout();
/*========================================================*/



  Future<Either<AppFailure, String?>> loadToken();
/*========================================================*/

  Future<Either<AppFailure, User>> loadUser();
/*========================================================*/

  Future<Either<AppFailure, Unit>> sendResetCodeToEmail(String email);
  /*========================================================*/
  
  Future<Either<AppFailure, Unit>> verifyResetCode(String email, String code, String newPassword);


  /*========================================================*/

  Future<Either<AppFailure, Unit>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

/*========================================================*/

  Future<Either<AppFailure, Unit>> requestChangeEmailCode();

/*========================================================*/

  Future<Either<AppFailure, Unit>> verifyChangeEmailCode({
    required String code,
    required String newEmail,
  });

}