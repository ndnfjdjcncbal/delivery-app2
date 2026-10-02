sealed class SignupEvent {}

class SignupButtonPressed extends SignupEvent {
  final String name;
  final String email;
  final String password;

  SignupButtonPressed({
    required this.name,
    required this.email,
    required this.password,
  });
}

class SignupCodeSubmitted extends SignupEvent {
  final String email;
  final String code;

  SignupCodeSubmitted({required this.email, required this.code});
}

class SignupCodeResendRequested extends SignupEvent {
  final String email;

  SignupCodeResendRequested(this.email);
}
