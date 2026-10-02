import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repo/auth_repo.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return repository.register(name, email, password);
  }
}
