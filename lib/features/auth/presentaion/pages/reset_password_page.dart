import 'package:delivert_app2/core/routes/app_routes.dart';
import 'package:delivert_app2/core/services/service_locator.dart';
import 'package:delivert_app2/features/auth/functions/auth_validitaor.dart';
import 'package:delivert_app2/features/auth/presentaion/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:delivert_app2/features/auth/presentaion/bloc/forgot_password/forgot_password_event.dart';
import 'package:delivert_app2/features/auth/presentaion/bloc/forgot_password/forgot_password_state.dart';
import 'package:delivert_app2/features/auth/presentaion/widget/TextFormField.dart';
import 'package:delivert_app2/features/auth/presentaion/widget/materialbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = arguments?['email']?.toString() ?? '';
    final code = arguments?['code']?.toString() ?? '';

    return BlocProvider<ForgotPasswordBloc>(
      create: (_) => sl<ForgotPasswordBloc>(),
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is ResetPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password updated successfully')),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      'Create new password',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Choose a strong password for your account',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildPasswordField(),
                    const SizedBox(height: 15),
                    _buildConfirmPasswordField(),
                    const SizedBox(height: 26),
                    _buildSubmitButton(context, email, code),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static final _formKey = GlobalKey<FormState>();
  static final _passwordController = TextEditingController();
  static final _confirmPasswordController = TextEditingController();

  Widget _buildPasswordField() {
    return _buildField(
      label: 'New password',
      hintText: 'Enter your new password',
      controller: _passwordController,
      validator: (value) => validinput(value.toString(), 8, 60, 'password'),
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildField(
      label: 'Confirm password',
      hintText: 'Confirm your new password',
      controller: _confirmPasswordController,
      validator: (value) {
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return validinput(value.toString(), 8, 60, 'password');
      },
    );
  }

  Widget _buildField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        textfieldauth(
          controller: controller,
          hintText: hintText,
          suffixIcon: const Icon(Icons.lock),
          obscureText: true,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, String email, String code) {
    return BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
      builder: (context, state) {
        if (state is ForgotPasswordLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Materialbutton(
          text: 'Update password',
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;

            context.read<ForgotPasswordBloc>().add(
              ResetPasswordRequested(
                email: email,
                code: code,
                password: _passwordController.text,
              ),
            );
          },
        );
      },
    );
  }
}
