import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repo/auth_repo.dart';

class RequestPasswordResetCodeUseCase {
  final AuthRepository repository;

  RequestPasswordResetCodeUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) {
    return repository.forgotPassword(email);
  }
}
