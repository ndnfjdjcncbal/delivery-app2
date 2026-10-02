import 'package:dartz/dartz.dart';
import 'package:delivert_app2/core/errors/failures.dart';
import 'package:delivert_app2/features/auth/domain/entiti/entity_login.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);

  Future<Either<Failure, void>> register(
    String name,
    String email,
    String password,
  );

  Future<Either<Failure, void>> verifyCode(String email, String code);

  Future<Either<Failure, void>> verifySignupCode(String email, String code);

  Future<Either<Failure, void>> resendCode(String email);

  Future<Either<Failure, void>> forgotPassword(String email);

  Future<Either<Failure, void>> resetPassword(
    String email,
    String code,
    String newPassword,
  );

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();
}
