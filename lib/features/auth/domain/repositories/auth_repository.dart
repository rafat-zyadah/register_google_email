import 'package:dartz/dartz.dart';

import '../../../../core/error/failure/failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {

  Future<Either<Failure,Unit >> registerUser({
    required String name,
    required String email,
    required String password,
  });
/*========================================================*/


  Future<Either<Failure, User>> verifyEmail({
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

}