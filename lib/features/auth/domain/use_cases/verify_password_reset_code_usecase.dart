import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repo/auth_repo.dart';

class VerifyPasswordResetCodeUseCase {
  final AuthRepository repository;

  VerifyPasswordResetCodeUseCase(this.repository);

  Future<Either<Failure, void>> call(String email, String code) {
    return repository.verifyCode(email, code);
  }
}