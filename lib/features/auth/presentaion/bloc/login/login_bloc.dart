import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase usecase;

  LoginBloc({required this.usecase}) : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());

      final response = await usecase.call(
        email: event.email,
        password: event.password,
      );

      response.fold(
        (failure) => emit(LoginFailure(failure.message)),
        (user) => emit(LoginSuccess(user)),
      );
    });
  }
}
