import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures/app_failure.dart';
import '../repositories/auth_repository.dart';
//Used to send a code to reset the password.
class SendResetCodeToEmailUseCase {
  final AuthRepository repository;
  SendResetCodeToEmailUseCase(this.repository);

  Future<Either<AppFailure, Unit>> call(String email) async {
    return await repository.sendResetCodeToEmail(email);
  }
}