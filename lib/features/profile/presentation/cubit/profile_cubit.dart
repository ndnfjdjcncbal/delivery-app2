import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/use_cases/request_password_reset_code_usecase.dart';
import '../../domain/use_cases/change_password_usecase.dart';
import '../../domain/use_cases/update_profile_image_usecase.dart';
import '../../domain/use_cases/update_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateProfileImageUseCase updateProfileImageUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final RequestPasswordResetCodeUseCase requestPasswordResetCodeUseCase;

  ProfileCubit({
    required this.updateProfileUseCase,
    required this.updateProfileImageUseCase,
    required this.changePasswordUseCase,
    required this.requestPasswordResetCodeUseCase,
  }) : super(const ProfileState());

  Future<void> requestPasswordResetCode({required String email}) async {
    emit(
      state.copyWith(
        isChangingPassword: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
        clearPasswordResetEmail: true,
        clearUpdatedUser: true,
        clearOperation: true,
      ),
    );

    final result = await requestPasswordResetCodeUseCase(email.trim());
    result.fold(
      (failure) => emit(
        state.copyWith(
          isChangingPassword: false,
          errorMessage: failure.message,
          operation: ProfileOperation.passwordResetRequest,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isChangingPassword: false,
          passwordResetEmail: email.trim(),
          successMessage: 'Verification code sent to your email.',
          operation: ProfileOperation.passwordResetRequest,
        ),
      ),
    );
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    emit(
      state.copyWith(
        isUpdatingProfile: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
        clearPasswordResetEmail: true,
        clearUpdatedUser: true,
        clearOperation: true,
      ),
    );

    final result = await updateProfileUseCase(name: name, email: email);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isUpdatingProfile: false,
          errorMessage: failure.message,
          operation: ProfileOperation.profile,
        ),
      ),
      (user) => emit(
        state.copyWith(
          isUpdatingProfile: false,
          updatedUser: user,
          successMessage: 'Profile updated successfully.',
          operation: ProfileOperation.profile,
        ),
      ),
    );
  }

  Future<void> updateProfileImage({required String imagePath}) async {
    emit(
      state.copyWith(
        isUpdatingImage: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
        clearPasswordResetEmail: true,
        clearUpdatedUser: true,
        clearOperation: true,
      ),
    );

    final result = await updateProfileImageUseCase(imagePath: imagePath);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isUpdatingImage: false,
          errorMessage: failure.message,
          operation: ProfileOperation.image,
        ),
      ),
      (user) => emit(
        state.copyWith(
          isUpdatingImage: false,
          updatedUser: user,
          successMessage: 'Profile photo updated.',
          operation: ProfileOperation.image,
        ),
      ),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(
      state.copyWith(
        isChangingPassword: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
        clearPasswordResetEmail: true,
        clearUpdatedUser: true,
        clearOperation: true,
      ),
    );

    final result = await changePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isChangingPassword: false,
          errorMessage: failure.message,
          operation: ProfileOperation.password,
        ),
      ),
      (action) => emit(
        state.copyWith(
          isChangingPassword: false,
          successMessage: action.message,
          operation: ProfileOperation.password,
        ),
      ),
    );
  }
}
