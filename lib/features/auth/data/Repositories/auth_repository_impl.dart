import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../data/local_data_source/auth_local_data_source.dart';
import '../../data/model/usermodel.dart';
import '../../domain/entiti/entity_login.dart';
import '../../domain/repo/auth_repo.dart';
import '../remote_data_source/auth_remot_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemotDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      print(response.data);
      final user = UserModel.fromJson(response.data).toEntity();
      if (user.id.isNotEmpty) {
        await localDataSource.saveUser(user);
        print(" user ${user.id}");
      }

      return Right(user);
    } on ServerException catch (e) {
      print('SERVER ERROR: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      print('NETWORK ERROR: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      print('UNKNOWN ERROR: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await remoteDataSource.register(name, email, password);
      final user = _parseUser(response.data);

      if (user.id.isNotEmpty) {
        await localDataSource.saveUser(user);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyCode(String email, String code) async {
    try {
      final response = await remoteDataSource.verifyCode(email, code);
      print(response);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifySignupCode(
    String email,
    String code,
  ) async {
    try {
      final response = await remoteDataSource.verifySignupCode(email, code);
      print(response);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendCode(String email) async {
    try {
      var respons = await remoteDataSource.resendCode(email);
      print(respons);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      final respnse = await remoteDataSource.forgotPassword(email);
      print(respnse);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.resetPassword(email, code, newPassword);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearUser();
      return const Right(null);
    } on ServerException catch (e) {
      await localDataSource.clearUser();
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      await localDataSource.clearUser();
      return Left(NetworkFailure(e.message));
    } catch (e) {
      await localDataSource.clearUser();
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final response = await remoteDataSource.getCurrentUser();
      final user = UserModel.fromJson(response.data).toEntity();
      if (user.id.isNotEmpty) {
        await localDataSource.saveUser(user);
      }
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  User _parseUser(dynamic data) {
    if (data is Map<String, dynamic>) {
      return UserModel.fromJson(data).toEntity();
    }

    if (data is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(data)).toEntity();
    }

    return const User(id: '', name: '', email: '');
  }
}
