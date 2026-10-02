sealed class ForgotPasswordEvent {}

class ForgotPasswordRequested extends ForgotPasswordEvent {
  final String email;

  ForgotPasswordRequested(this.email);
}

class ForgotPasswordCodeSubmitted extends ForgotPasswordEvent {
  final String email;
  final String code;

  ForgotPasswordCodeSubmitted({required this.email, required this.code});
}

class ForgotPasswordCodeResendRequested extends ForgotPasswordEvent {
  final String email;

  ForgotPasswordCodeResendRequested(this.email);
}

class ResetPasswordRequested extends ForgotPasswordEvent {
  final String email;
  final String code;
  final String password;

  ResetPasswordRequested({
    required this.email,
    required this.code,
    required this.password,
  });
}
