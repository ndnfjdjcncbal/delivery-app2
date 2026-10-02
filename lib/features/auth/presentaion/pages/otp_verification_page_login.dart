import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_color/Colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/service_locator.dart';
import '../bloc/forgot_password/forgot_password_bloc.dart';
import '../bloc/forgot_password/forgot_password_event.dart';
import '../bloc/forgot_password/forgot_password_state.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final codeController = TextEditingController();
  late String email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    email = (ModalRoute.of(context)?.settings.arguments as String?) ?? '';
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ForgotPasswordBloc>(),
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is ForgotPasswordCodeVerified) {
            Navigator.pushNamed(
              context,
              AppRoutes.resetPassword,
              arguments: {'email': email, 'code': codeController.text.trim()},
            );
          }
          if (state is ForgotPasswordCodeResent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('A new code was sent to your email.'),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundGrey,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundGrey,
            elevation: 0,
            title: const Text(
              'Verify your email',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.black),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                builder: (context, state) {
                  final isLoading = state is ForgotPasswordLoading;
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPale,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: const Icon(
                            Icons.mark_email_read_outlined,
                            size: 42,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Check your inbox',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We sent a 5-digit code to your email address',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.grey,
                            height: 1.4,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: codeController,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 5,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 12,
                            color: AppColors.black,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '00000',
                            hintStyle: const TextStyle(
                              color: AppColors.grey,
                              letterSpacing: 12,
                            ),
                            filled: true,
                            fillColor: AppColors.lightGrey,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _verify(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Verify code',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.read<ForgotPasswordBloc>().add(
                                  ForgotPasswordCodeResendRequested(email),
                                ),
                          child: const Text(
                            'Resend code',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _verify(BuildContext context) {
    final code = codeController.text.trim();
    if (code.length != 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter the 5-digit code.')));
      return;
    }
    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordCodeSubmitted(email: email, code: code),
    );
  }
}
