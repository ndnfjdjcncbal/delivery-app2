import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_client/link_api.dart';
import '../../../../core/network/api_consumer.dart';
import '../models/profile_action_model.dart';

class ProfileRemoteDataSource {
  final ApiConsumer apiConsumer;

  ProfileRemoteDataSource(this.apiConsumer);

  Future<ProfileActionModel> updateProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    final response = await apiConsumer.post(
      ApiConstants.updateprofile,
      data: FormData.fromMap({
        'user_id': userId,
        'user_name': name,
        'user_email': email,
      }),
    );
    return ProfileActionModel.fromJson(response.data);
  }

  Future<ProfileActionModel> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await apiConsumer.post(
      ApiConstants.changepassword,
      data: FormData.fromMap({
        'user_id': userId,
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );
    return ProfileActionModel.fromJson(response.data);
  }

  Future<ProfileActionModel> updateProfileImage({
    required String userId,
    required String imagePath,
  }) async {
    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw const FormatException('The selected profile photo is unavailable.');
    }

    final response = await apiConsumer.post(
      ApiConstants.updateimage,
      data: FormData.fromMap({
        'user_id': userId,
        'user_image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split(Platform.pathSeparator).last,
        ),
      }),
    );
    return ProfileActionModel.fromJson(response.data);
  }
}
