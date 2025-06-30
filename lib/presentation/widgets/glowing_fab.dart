import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../helpers/color_manager.dart';

class GlowingFAB extends StatefulWidget {
  final bool isAdmin;
  final VoidCallback onPressed;

  const GlowingFAB({
    super.key,
    required this.isAdmin,
    required this.onPressed,
  });

  @override
  State<GlowingFAB> createState() => _GlowingFABState();
}

class _GlowingFABState extends State<GlowingFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return FloatingActionButton(
          heroTag: null,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: widget.onPressed,
          child: Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [ColorManager.gradientStart, ColorManager.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: _glowAnimation.value),
                  blurRadius: 20.r,
                  spreadRadius: 1.r,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.isAdmin ? Icons.analytics_outlined : Icons.add,
                color: Colors.white,
                size: 34.sp,
              ),
            ),
          ),
        );
      },
    );
  }
}
