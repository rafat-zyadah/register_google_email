import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures/app_failure.dart';

class LoadToken {
  final AuthRepository repository;

  LoadToken(this.repository);

  Future<Either<AppFailure, String?>> call() async {
    return await repository.loadToken();
  }
}
