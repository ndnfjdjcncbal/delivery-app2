import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repo/auth_repo.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String code,
    required String password,
  }) {
    return repository.resetPassword(email, code, password);
  }
}