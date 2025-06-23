import 'package:flutter/material.dart';
import 'font_weight_helper.dart';

class TextStyles {
  static TextStyle font14GreyRegular = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,
    color: Colors.grey,
  );
  static TextStyle font16WhiteRegular = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );
  static TextStyle font14GreyMedium = const TextStyle(
      fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500);
  static TextStyle font16GreyMedium = const TextStyle(
      fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500);
  static TextStyle font16BlackRegular = const TextStyle(
      fontSize: 16, color: Colors.black, fontWeight: FontWeightHelper.regular);
  static TextStyle font15BlackRegular = const TextStyle(
      fontSize: 15, color: Colors.black, fontWeight: FontWeightHelper.regular);
}
