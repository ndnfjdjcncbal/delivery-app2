import 'package:dartz/dartz.dart';
import 'package:delivert_app2/features/auth/domain/entiti/entity_login.dart';

import '../../../../core/errors/failures.dart';
import '../repo/auth_repo.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) {
    return repository.login(email, password);
  }
}
