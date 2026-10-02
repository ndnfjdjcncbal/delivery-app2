import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_color/Colors.dart';

class WarningDialog {
  final BuildContext context;
  final String title;
  final String desc;
  final VoidCallback onOkPressed;
  final VoidCallback onCancelPressed;

  WarningDialog({
    required this.context,
    required this.title,
    required this.desc,
    required this.onOkPressed,
    required this.onCancelPressed,
  });

  void show() {
    if (!context.mounted) return;

    AwesomeDialog(
      context: context,
      dialogBackgroundColor: AppColors.white,
      btnCancelColor: AppColors.grey,
      btnOkColor: AppColors.primary,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      title: title,
      desc: desc,
      titleTextStyle: const TextStyle(
        color: AppColors.black,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      descTextStyle: const TextStyle(
        color: AppColors.grey,
        fontSize: 14,
        height: 1.4,
      ),
      buttonsBorderRadius: BorderRadius.circular(12),
      btnOkOnPress: onOkPressed,
      btnCancelOnPress: onCancelPressed,
    ).show();
  }
}
