import 'package:dartz/dartz.dart';

import '../../../../core/error/failure/failure.dart';
import '../repositories/auth_repository.dart';

class LoadToken {
  final AuthRepository repository;

  LoadToken(this.repository);

  Future<Either<Failure, String?>> call() async {
    return await repository.loadToken();
  }
}
