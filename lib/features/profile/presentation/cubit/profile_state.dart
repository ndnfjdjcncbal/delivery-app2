import 'package:equatable/equatable.dart';

import '../../../auth/domain/entiti/entity_login.dart';

enum ProfileOperation { profile, image, password, passwordResetRequest }

class ProfileState extends Equatable {
  final bool isUpdatingProfile;
  final bool isUpdatingImage;
  final bool isChangingPassword;
  final String? errorMessage;
  final String? successMessage;
  final String? passwordResetEmail;
  final User? updatedUser;
  final ProfileOperation? operation;

  const ProfileState({
    this.isUpdatingProfile = false,
    this.isUpdatingImage = false,
    this.isChangingPassword = false,
    this.errorMessage,
    this.successMessage,
    this.passwordResetEmail,
    this.updatedUser,
    this.operation,
  });

  ProfileState copyWith({
    bool? isUpdatingProfile,
    bool? isUpdatingImage,
    bool? isChangingPassword,
    String? errorMessage,
    String? successMessage,
    String? passwordResetEmail,
    User? updatedUser,
    ProfileOperation? operation,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    bool clearPasswordResetEmail = false,
    bool clearUpdatedUser = false,
    bool clearOperation = false,
  }) {
    return ProfileState(
      isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
      isUpdatingImage: isUpdatingImage ?? this.isUpdatingImage,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
      passwordResetEmail: clearPasswordResetEmail
          ? null
          : (passwordResetEmail ?? this.passwordResetEmail),
      updatedUser: clearUpdatedUser ? null : (updatedUser ?? this.updatedUser),
      operation: clearOperation ? null : (operation ?? this.operation),
    );
  }

  @override
  List<Object?> get props => [
    isUpdatingProfile,
    isUpdatingImage,
    isChangingPassword,
    errorMessage,
    successMessage,
    passwordResetEmail,
    updatedUser,
    operation,
  ];
}
