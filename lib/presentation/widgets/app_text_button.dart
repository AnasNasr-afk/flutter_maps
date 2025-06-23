import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextButton extends StatelessWidget {
  final void Function() onPressed;
  final Text text;
  final ButtonStyle? buttonStyle;

  const AppTextButton(
      {super.key,
      required this.onPressed,
      required this.text,
      this.buttonStyle});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: buttonStyle ??
          ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(Colors.black),
            minimumSize:  WidgetStatePropertyAll(
              Size(80.w, 50.h),
            ),
            shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
          ),
      child: text ,

    );
  }
}
