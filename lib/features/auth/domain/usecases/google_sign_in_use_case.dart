import 'package:dartz/dartz.dart';
import '../../../../core/error/failure/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.signInWithGoogle();
  }
}
