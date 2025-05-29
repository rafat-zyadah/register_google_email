import 'package:dartz/dartz.dart';

import '../../../../core/error/failure/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoadUserUseCase {
  final AuthRepository repository;

  LoadUserUseCase(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.loadUser();
  }
}
