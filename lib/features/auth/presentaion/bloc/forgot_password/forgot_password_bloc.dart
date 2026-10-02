import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/request_password_reset_code_usecase.dart';
import '../../../domain/use_cases/resend_password_reset_code_usecase.dart';
import '../../../domain/use_cases/reset_password_usecase.dart';
import '../../../domain/use_cases/verify_password_reset_code_usecase.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final RequestPasswordResetCodeUseCase requestCodeUseCase;
  final VerifyPasswordResetCodeUseCase verifyCodeUseCase;
  final ResendPasswordResetCodeUseCase resendCodeUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  ForgotPasswordBloc({
    required this.requestCodeUseCase,
    required this.verifyCodeUseCase,
    required this.resendCodeUseCase,
    required this.resetPasswordUseCase,
  }) : super(ForgotPasswordInitial()) {
    on<ForgotPasswordRequested>((event, emit) async {
      emit(ForgotPasswordLoading());

      final response = await requestCodeUseCase.call(event.email);

      response.fold(
        (failure) => emit(ForgotPasswordFailure(failure.message)),
        (_) => emit(ForgotPasswordCodeSent()),
      );
    });

    on<ForgotPasswordCodeSubmitted>((event, emit) async {
      emit(ForgotPasswordLoading());

      final response = await verifyCodeUseCase.call(event.email, event.code);

      response.fold(
        (failure) => emit(ForgotPasswordFailure(failure.message)),
        (_) => emit(ForgotPasswordCodeVerified()),
      );
    });

    on<ForgotPasswordCodeResendRequested>((event, emit) async {
      emit(ForgotPasswordLoading());

      final response = await resendCodeUseCase.call(event.email);

      response.fold(
        (failure) => emit(ForgotPasswordFailure(failure.message)),
        (_) => emit(ForgotPasswordCodeResent()),
      );
    });

    on<ResetPasswordRequested>((event, emit) async {
      emit(ForgotPasswordLoading());

      final response = await resetPasswordUseCase.call(
        email: event.email,
        code: event.code,
        password: event.password,
      );

      response.fold(
        (failure) => emit(ForgotPasswordFailure(failure.message)),
        (_) => emit(ResetPasswordSuccess()),
      );
    });
  }
}
