import 'package:delivert_app2/features/auth/domain/entiti/entity_login.dart';

sealed class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  User user;

  LoginSuccess(this.user);
}

class LoginFailure extends LoginState {
  String message;

  LoginFailure(this.message);
}
