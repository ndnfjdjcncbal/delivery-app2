import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repo/auth_repo.dart';

class VerifySignupCodeUseCase {
  final AuthRepository repository;

  VerifySignupCodeUseCase(this.repository);

  Future<Either<Failure, void>> call(String email, String code) {
    return repository.verifySignupCode(email, code);
  }
}
