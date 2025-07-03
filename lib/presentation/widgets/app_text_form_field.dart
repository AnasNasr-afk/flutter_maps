

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../helpers/color_manager.dart';
import '../../helpers/text_styles.dart';

class AppTextFormField extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final Widget? suffixIcon;
  final String hintText;
  final String? prefixText;
  final bool? isObscureText;
  final Color? backgroundColor;
  final bool? enabled;
  final int? maxLines;
  final int? minLines;
  final String? helperText;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final Function(String?) validator;
  final int? maxLength;
  final bool? readOnly;
  final Widget? prefixIcon;

  const AppTextFormField({super.key,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.inputTextStyle,
    this.hintStyle,
    this.suffixIcon,
    required this.hintText,
    this.isObscureText,
    this.backgroundColor,
    this.controller,
    required this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.textInputType,
    this.prefixText,
    this.enabled,
    this.maxLines,
    this.keyboardType,
    this.minLines,
    this.textInputAction,
    this.helperText,
    this.maxLength,
     this.readOnly, this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      controller: controller,
      decoration: InputDecoration(
        prefixText: prefixText,
        isDense: true,
        contentPadding: contentPadding ??
             EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 18.h,
            ),

        focusedBorder: focusedBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorManager.mainBlue,
                width: 1.3.w,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
        enabledBorder: enabledBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.3.w,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.3.w,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.3.w,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        hintStyle: hintStyle ??
            TextStyles.font14GreyMedium,
        hintText: hintText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: backgroundColor ??
            Colors.white,
      ),
      maxLines: maxLines,
      minLines: minLines,

      obscureText: isObscureText ?? false,
      style: inputTextStyle ??
          TextStyles.font16BlackRegular,
      validator: (value){
        return validator(value);
      },
    );
  }
}