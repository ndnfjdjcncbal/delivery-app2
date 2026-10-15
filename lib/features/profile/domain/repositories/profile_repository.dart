import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entiti/entity_login.dart';
import '../entities/profile_action.dart';

abstract class ProfileRepository {
  Future<Either<Failure, User>> updateProfile({
    required String name,
    required String email,
  });

  Future<Either<Failure, User>> updateProfileImage({required String imagePath});

  Future<Either<Failure, ProfileAction>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
