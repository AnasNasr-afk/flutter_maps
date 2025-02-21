

import 'package:flutter/material.dart';
import 'package:flutter_maps/helpers/color_manager.dart';

class TextStyles {
  static const TextStyle font12MainBlueBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: ColorManager.mainBlue,
  );

  static const TextStyle font16WhiteMedium = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  )
  ;static const TextStyle font16BlackMedium = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle font14GreyMedium = TextStyle(
    fontSize: 14,
    color: Colors.black54,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle font14DarkBlueMedium = TextStyle(
    fontSize: 14,
    color: ColorManager.mainBlue,
    fontWeight: FontWeight.w600,
  );
}