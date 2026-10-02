import 'package:delivert_app2/features/auth/presentaion/bloc/signup/signup_event.dart';
import 'package:delivert_app2/features/auth/presentaion/bloc/signup/signup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/register_usecase.dart';
import '../../../domain/use_cases/resend_password_reset_code_usecase.dart';
import '../../../domain/use_cases/verify_signup_code_usecase.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final RegisterUseCase usecase;
  final VerifySignupCodeUseCase verifySignupCodeUseCase;
  final ResendPasswordResetCodeUseCase resendCodeUseCase;

  SignupBloc({
    required this.usecase,
    required this.verifySignupCodeUseCase,
    required this.resendCodeUseCase,
  }) : super(SignupInitial()) {
    on<SignupButtonPressed>((event, emit) async {
      emit(SignupLoading());

      final response = await usecase.call(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      response.fold(
        (failure) => emit(SignupFailure(failure.message)),
        (_) => emit(SignupSuccess(event.email)),
      );
    });

    on<SignupCodeSubmitted>((event, emit) async {
      emit(SignupLoading());
      final response = await verifySignupCodeUseCase.call(
        event.email,
        event.code,
      );

      response.fold(
        (failure) => emit(SignupFailure(failure.message)),
        (_) => emit(SignupCodeVerified()),
      );
    });

    on<SignupCodeResendRequested>((event, emit) async {
      emit(SignupLoading());
      final response = await resendCodeUseCase.call(event.email);

      response.fold(
        (failure) => emit(SignupFailure(failure.message)),
        (_) => emit(SignupCodeResent()),
      );
    });
  }
}
