import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures/app_failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<Either<AppFailure, User>> call() async {
    return await repository.signInWithGoogle();
  }
}
