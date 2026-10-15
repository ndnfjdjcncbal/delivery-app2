import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/data/local_data_source/auth_local_data_source.dart';
import '../../../auth/domain/entiti/entity_login.dart';
import '../../domain/entities/profile_action.dart';
import '../../domain/repositories/profile_repository.dart';
import '../remote_data_source/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  ProfileRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, User>> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final currentUser = await localDataSource.getUser();
      if (currentUser == null || currentUser.id.isEmpty) {
        return Left(ServerFailure('User information is unavailable.'));
      }

      await remoteDataSource.updateProfile(
        userId: currentUser.id,
        name: name.trim(),
        email: email.trim(),
      );

      final updatedUser = User(
        id: currentUser.id,
        name: name.trim(),
        email: email.trim(),
        phone: currentUser.phone,
        image: currentUser.image,
      );
      await localDataSource.saveUser(updatedUser);
      return Right(updatedUser);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    } on FormatException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return Left(ServerFailure('Could not update your profile.'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfileImage({
    required String imagePath,
  }) async {
    try {
      final currentUser = await localDataSource.getUser();
      if (currentUser == null || currentUser.id.isEmpty) {
        return Left(ServerFailure('User information is unavailable.'));
      }

      final result = await remoteDataSource.updateProfileImage(
        userId: currentUser.id,
        imagePath: imagePath,
      );
      final updatedImage = result.image ?? await _persistProfileImage(
        imagePath,
        currentUser.id,
      );
      final updatedUser = User(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        phone: currentUser.phone,
        image: updatedImage,
      );
      await localDataSource.saveUser(updatedUser);
      return Right(updatedUser);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    } on FormatException catch (error) {
      return Left(ServerFailure(error.message));
    } on FileSystemException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return Left(ServerFailure('Could not update your profile photo.'));
    }
  }

  Future<String> _persistProfileImage(String imagePath, String userId) async {
    final source = File(imagePath);
    if (!await source.exists()) {
      throw const FormatException('The selected profile photo is unavailable.');
    }

    final appDirectory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory('${appDirectory.path}/profile_images');
    await imageDirectory.create(recursive: true);
    final safeUserId = userId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final destination = '${imageDirectory.path}/profile_$safeUserId.jpg';
    return (await source.copy(destination)).path;
  }

  @override
  Future<Either<Failure, ProfileAction>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final currentUser = await localDataSource.getUser();
      if (currentUser == null || currentUser.id.isEmpty) {
        return Left(ServerFailure('User information is unavailable.'));
      }

      final result = await remoteDataSource.changePassword(
        userId: currentUser.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return Right(result.toEntity());
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    } on FormatException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return Left(ServerFailure('Could not change your password.'));
    }
  }
}
