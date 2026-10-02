sealed class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordCodeSent extends ForgotPasswordState {}

class ForgotPasswordCodeVerified extends ForgotPasswordState {}

class ForgotPasswordCodeResent extends ForgotPasswordState {}

class ResetPasswordSuccess extends ForgotPasswordState {}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String message;

  ForgotPasswordFailure(this.message);
}
