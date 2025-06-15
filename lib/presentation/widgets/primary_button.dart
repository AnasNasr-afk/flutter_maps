import 'package:flutter/material.dart';
import '../../helpers/color_manager.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  final TextStyle? textStyle;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Widget? child;


  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 14,
    this.fontWeight = FontWeight.bold,
    this.textStyle,
    this.width = 340,
    this.height = 49,
    this.backgroundColor ,
    this.textColor ,
    this.borderRadius = 30,
    this.boxShadow,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: boxShadow,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          alignment: Alignment.center,
          backgroundColor: WidgetStatePropertyAll(backgroundColor ?? ColorManager.secondary),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          fixedSize: WidgetStatePropertyAll(
            Size(width, height),
          ),
        ),
        child: Text(
          text,
          style: textStyle ??
              TextStyle(
                color: textColor ?? ColorManager.white,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
        ),
      ),
    );
  }
}
