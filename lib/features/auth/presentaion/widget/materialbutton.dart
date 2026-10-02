import 'package:flutter/material.dart';

import '../../../../core/constants/app_color/Colors.dart';

class Materialbutton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const Materialbutton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColors.primary,
        ),
        child: MaterialButton(
          onPressed: onPressed,
          child: Text(text, style: const TextStyle(color: AppColors.white)),
        ),
      ),
    );
  }
}
