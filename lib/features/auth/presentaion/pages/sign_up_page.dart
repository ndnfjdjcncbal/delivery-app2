import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../functions/auth_validitaor.dart';
import '../bloc/signup/signup_bloc.dart';
import '../bloc/signup/signup_event.dart';
import '../bloc/signup/signup_state.dart';
import '../widget/TextFormField.dart';
import '../widget/materialbutton.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  static final _formKey = GlobalKey<FormState>();
  static final _emailController = TextEditingController();
  static final _nameController = TextEditingController();
  static final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignupBloc>(
      create: (_) => sl<SignupBloc>(),
      child: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is SignupSuccess) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.signupVerification,
              arguments: state.email,
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildNameField(),
                    const SizedBox(height: 18),
                    _buildEmailField(),
                    const SizedBox(height: 18),
                    _buildPasswordField(),
                    const SizedBox(height: 26),
                    _buildSubmitButton(),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 22),
                    _buildSocialButtons(),
                    const SizedBox(height: 20),
                    _buildLoginPrompt(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Text(
          'Create account',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Signin to continue',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return _buildField(
      label: 'Full name',
      hintText: 'Enter Your Name',
      icon: Icons.person,
      controller: _nameController,
      validator: (value) => validinput(value.toString(), 15, 60, 'username'),
    );
  }

  Widget _buildEmailField() {
    return _buildField(
      label: 'Email address',
      hintText: 'Enter Your Email',
      icon: Icons.email,
      controller: _emailController,
      validator: (value) => validinput(value.toString(), 5, 100, 'email'),
    );
  }

  Widget _buildPasswordField() {
    return _buildField(
      label: 'Password',
      hintText: 'Password',
      icon: Icons.lock,
      controller: _passwordController,
      validator: (value) => validinput(value.toString(), 8, 60, 'password'),
    );
  }

  Widget _buildField({
    required String label,
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        textfieldauth(
          controller: controller,
          hintText: hintText,
          suffixIcon: Icon(icon),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        if (state is SignupLoading) {
          return const SizedBox(
            width: double.infinity,
            height: 52,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Materialbutton(
          text: 'Create account',
          onPressed: () => _submitForm(context),
        );
      },
    );
  }

  void _submitForm(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<SignupBloc>().add(
      SignupButtonPressed(
        name: _nameController.text.trim().toString(),
        email: _emailController.text.trim().toString(),
        password: _passwordController.text.trim().toString(),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.g_mobiledata),
            label: const Text('Continue with Google'),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.facebook),
            label: const Text('Continue with Facebook'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account? '),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.login);
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}
