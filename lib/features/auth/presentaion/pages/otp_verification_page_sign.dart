import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../../../../core/constants/app_color/Colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/service_locator.dart';
import '../bloc/signup/signup_bloc.dart';
import '../bloc/signup/signup_event.dart';
import '../bloc/signup/signup_state.dart';

class SignupVerificationPage extends StatefulWidget {
  const SignupVerificationPage({super.key});

  @override
  State<SignupVerificationPage> createState() => _SignupVerificationPageState();
}

class _SignupVerificationPageState extends State<SignupVerificationPage> {
  List<TextEditingController?> _otpControllers = [];
  late String _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignupBloc>(
      create: (_) => sl<SignupBloc>(),
      child: BlocListener<SignupBloc, SignupState>(
        listener: _handleState,
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            toolbarHeight: 70.3,
            shape: const Border(
              bottom: BorderSide(color: AppColors.black, width: 1),
            ),
            backgroundColor: AppColors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Verify your email',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            iconTheme: const IconThemeData(color: AppColors.black),
          ),
          body: SafeArea(
            child: BlocBuilder<SignupBloc, SignupState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildContent(context, isLoading: state is SignupLoading),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleState(BuildContext context, SignupState state) {
    if (state is SignupFailure) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message)));
    }

    if (state is SignupCodeResent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code was sent to your email.')),
      );
    }

    if (state is SignupCodeVerified) {
      showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 38, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F8EF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.newBadge,
                    size: 58,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Register Success',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Congratulations! Your account has been created.\nPlease log in to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: const Text('Go to login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildContent(BuildContext context, {required bool isLoading}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 9),
        _buildIcon(),
        const SizedBox(height: 19),
        const Text(
          'Verification Code',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'We sent a verification code to',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.grey, height: 1.4, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          _email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _buildCodeField(context, isLoading: isLoading),
        const SizedBox(height: 50),
        _buildVerifyButton(context, isLoading),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't receive the code?",
              style: TextStyle(color: AppColors.grey, fontSize: 12),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => context.read<SignupBloc>().add(
                      SignupCodeResendRequested(_email),
                    ),
              child: const Text(
                'Resend',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return SizedBox(
      width: 180,
      height: 180,
      child: Center(
        child: Container(
          width: 108,
          height: 108,
          decoration: const BoxDecoration(
            color: AppColors.primaryPale,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 34,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField(BuildContext context, {required bool isLoading}) {
    return OtpTextField(
      numberOfFields: 5,
      fieldWidth: 40,
      fieldHeight: 54,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      autoFocus: true,
      enabled: !isLoading,
      showFieldAsBox: true,
      filled: true,
      fillColor: AppColors.white,
      borderWidth: 1.5,
      borderRadius: BorderRadius.circular(12),
      enabledBorderColor: AppColors.grey2,
      focusedBorderColor: AppColors.primary,
      disabledBorderColor: AppColors.grey2,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
      handleControllers: (controllers) => _otpControllers = controllers,
      onSubmit: (code) {
        if (!isLoading) _verifyCode(context, code: code);
      },
    );
  }

  Widget _buildVerifyButton(BuildContext context, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _verifyCode(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primaryLight,
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
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Submit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  void _verifyCode(BuildContext context, {String? code}) {
    final verificationCode =
        code ??
        _otpControllers.map((controller) => controller?.text ?? '').join();
    if (verificationCode.length != 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter the 5-digit code.')));
      return;
    }

    context.read<SignupBloc>().add(
      SignupCodeSubmitted(email: _email, code: verificationCode),
    );
  }
}
