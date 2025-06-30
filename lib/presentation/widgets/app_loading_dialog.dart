import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppLoadingDialog extends StatelessWidget {
  final Color? color;
  final double? size;

  const AppLoadingDialog({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.inkDrop(
        color: color ?? Colors.blueAccent,
        size: size ?? 55.sp,
      ),
    );
  }
}
