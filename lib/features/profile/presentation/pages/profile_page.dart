import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_color/Colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../auth/domain/entiti/entity_login.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../validators/profile_validators.dart';
import '../widgets/password_reset_request_sheet.dart';

class ProfilePage extends StatelessWidget {
  final User? user;
  final ValueChanged<User> onUserUpdated;
  final Future<void> Function() onLogout;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onUserUpdated,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => sl<ProfileCubit>(),
      child: _ProfileView(
        user: user,
        onUserUpdated: onUserUpdated,
        onLogout: onLogout,
      ),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final User? user;
  final ValueChanged<User> onUserUpdated;
  final Future<void> Function() onLogout;

  const _ProfileView({
    required this.user,
    required this.onUserUpdated,
    required this.onLogout,
  });

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _isEditing = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _syncUser(widget.user);
  }

  @override
  void didUpdateWidget(covariant _ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user && !_isEditing) {
      _syncUser(widget.user);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _syncUser(User? user) {
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _imagePath = user?.image;
  }

  Future<void> _pickProfileImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;
      await context.read<ProfileCubit>().updateProfileImage(
        imagePath: image.path,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not select profile photo: $error')),
      );
    }
  }

  Future<void> _requestPasswordReset() async {
    final profileCubit = context.read<ProfileCubit>();
    final emailController = TextEditingController(
      text: widget.user?.email ?? '',
    );
    final formKey = GlobalKey<FormState>();
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => BlocProvider.value(
          value: profileCubit,
          child: PasswordResetRequestSheet(
            emailController: emailController,
            formKey: formKey,
          ),
        ),
      );
    } finally {
      emailController.dispose();
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || widget.user == null) return;
    await context.read<ProfileCubit>().updateProfile(
      name: _nameController.text,
      email: _emailController.text,
    );
  }

  void _cancelEditing() {
    _syncUser(widget.user);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.operation == ProfileOperation.passwordResetRequest) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          } else if (state.passwordResetEmail != null) {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(
              AppRoutes.otpVerification,
              arguments: state.passwordResetEmail,
            );
          }
          return;
        }
        if (state.errorMessage != null &&
            state.operation != ProfileOperation.password) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state.successMessage != null &&
            state.operation != ProfileOperation.password) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.successMessage!)));
          final updatedUser = state.updatedUser;
          if (updatedUser != null) {
            widget.onUserUpdated(updatedUser);
            if (state.operation == ProfileOperation.profile) {
              _syncUser(updatedUser);
              setState(() => _isEditing = false);
            } else if (state.operation == ProfileOperation.image) {
              setState(() => _imagePath = updatedUser.image);
            }
          }
        }
      },
      builder: (context, state) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primaryPale,
                        child: ClipOval(child: _profileImage()),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: IconButton(
                            onPressed: state.isUpdatingImage
                                ? null
                                : _pickProfileImage,
                            tooltip: 'Change profile photo',
                            icon: state.isUpdatingImage
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_rounded,
                                    color: AppColors.white,
                                    size: 18,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.user?.name ?? 'Delivery User',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  readOnly: !_isEditing,
                  validator: ProfileValidators.validateName,
                  textInputAction: TextInputAction.next,
                  decoration: _profileFieldDecoration(
                    label: 'Name',
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  readOnly: !_isEditing,
                  validator: ProfileValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: _profileFieldDecoration(
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: widget.user?.phone?.isNotEmpty == true
                      ? widget.user!.phone
                      : 'No phone',
                  readOnly: true,
                  decoration: _profileFieldDecoration(
                    label: 'Phone',
                    icon: Icons.phone_outlined,
                  ),
                ),
                const SizedBox(height: 22),
                TextButton.icon(
                  onPressed: _requestPasswordReset,
                  icon: const Icon(Icons.lock_reset_rounded),
                  label: const Text('Change password'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                const SizedBox(height: 8),
                if (!_isEditing)
                  ElevatedButton.icon(
                    onPressed: widget.user == null
                        ? null
                        : () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit Profile'),
                    style: _profileButtonStyle(),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: state.isUpdatingProfile ? null : _saveProfile,
                    icon: state.isUpdatingProfile
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      state.isUpdatingProfile ? 'Saving...' : 'Save Changes',
                    ),
                    style: _profileButtonStyle(),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: state.isUpdatingProfile ? null : _cancelEditing,
                    child: const Text('Cancel'),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileImage() {
    final path = _imagePath;
    if (path == null || path.isEmpty) {
      return const Icon(
        Icons.person_rounded,
        size: 48,
        color: AppColors.primary,
      );
    }

    final isNetworkImage =
        path.startsWith('http://') || path.startsWith('https://');
    return SizedBox(
      width: 96,
      height: 96,
      child: isNetworkImage
          ? Image.network(
              path,
              fit: BoxFit.cover,
              errorBuilder: _profileImageFallback,
            )
          : Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: _profileImageFallback,
            ),
    );
  }

  Widget _profileImageFallback(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Icon(Icons.person_rounded, size: 48, color: AppColors.primary);
  }

  InputDecoration _profileFieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6E2FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  ButtonStyle _profileButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      minimumSize: const Size.fromHeight(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
