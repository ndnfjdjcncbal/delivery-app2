import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repo/auth_repo.dart';

class ResendPasswordResetCodeUseCase {
  final AuthRepository repository;

  ResendPasswordResetCodeUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) {
    return repository.resendCode(email);
  }
}