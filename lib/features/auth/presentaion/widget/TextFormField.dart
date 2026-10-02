import 'package:flutter/material.dart';

import '../../../../core/constants/app_color/Colors.dart';

class textfieldauth extends StatelessWidget {
  final String? hintText;
  final Widget? suffixIcon;
  final bool? obscureText;
  final void Function()? onTap;
  String? Function(String?) validator;
  final TextEditingController? controller;

  textfieldauth({
    Key? key,
    required this.validator,
    required this.hintText,
    required this.suffixIcon,
    required this.controller,
    this.obscureText,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(40),
      ),
      child: TextFormField(
        textAlign: TextAlign.left,
        obscureText: obscureText == null || obscureText == false
            ? false
            : true, //هنا بنقول ان القيمه اللي هتتحط  لو نل خليها فالسي ولو فالسي خليها فالسي ولو العكس هيبقي ترو وهيا هتبقي ترو لاف صفحة الكونترولر بدانا ب الترو
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          alignLabelWithHint: true,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFF6C63FF), width: 1.5),
          ),

          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: InkWell(onTap: onTap, child: suffixIcon),
        ),
        enabled: true,
      ),
    );
  }
}
