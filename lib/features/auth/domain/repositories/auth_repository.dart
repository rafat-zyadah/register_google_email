import 'package:dartz/dartz.dart';

import '../../../../core/error/failure/failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {

  Future<Either<Failure,Unit >> registerUser({
    required String email,
    required String password,
  });
/*========================================================*/


  Future<Either<Failure, Unit>> verifyEmail({
    required String email,
    required String code,
  });
/*========================================================*/
  Future<Either<Failure, User>> signInWithGoogle();
/*========================================================*/
  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  });
/*========================================================*/
Future<Either<Failure, Unit>> logout();
/*========================================================*/



  Future<Either<Failure, String?>> loadToken();
/*========================================================*/

  Future<Either<Failure, User>> loadUser();
/*========================================================*/

  Future<Either<Failure, Unit>> sendResetCodeToEmail(String email);
  /*========================================================*/
  
  Future<Either<Failure, Unit>> verifyResetCode(String email, String code, String newPassword);


  /*========================================================*/

  Future<Either<Failure, Unit>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

/*========================================================*/

  Future<Either<Failure, Unit>> requestChangeEmailCode();

/*========================================================*/

  Future<Either<Failure, Unit>> verifyChangeEmailCode({
    required String code,
    required String newEmail,
  });

}