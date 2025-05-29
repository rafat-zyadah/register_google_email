import 'package:dartz/dartz.dart';
import '../../../../core/error/failure/failure.dart';
import '../repositories/auth_repository.dart';
//Used to send a code to reset the password.
class SendResetCodeToEmailUseCase {
  final AuthRepository repository;
  SendResetCodeToEmailUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String email) async {
    return await repository.sendResetCodeToEmail(email);
  }
}