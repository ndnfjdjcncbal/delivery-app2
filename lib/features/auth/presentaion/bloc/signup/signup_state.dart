sealed class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final String email;

  SignupSuccess(this.email);
}

class SignupCodeVerified extends SignupState {}

class SignupCodeResent extends SignupState {}

class SignupFailure extends SignupState {
  final String message;

  SignupFailure(this.message);
}
