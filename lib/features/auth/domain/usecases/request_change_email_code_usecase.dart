import 'package:dartz/dartz.dart';
import '../../../../core/error/failure/failure.dart';
import '../repositories/auth_repository.dart';

class RequestChangeEmailCodeUseCase {
  final AuthRepository repository;

  RequestChangeEmailCodeUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return repository.requestChangeEmailCode();
  }
}
