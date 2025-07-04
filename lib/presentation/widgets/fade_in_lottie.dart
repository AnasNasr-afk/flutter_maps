import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class FadeInLottieAnimation extends StatefulWidget {
  const FadeInLottieAnimation({super.key});

  @override
  State<FadeInLottieAnimation> createState() => _FadeInLottieAnimationState();
}

class _FadeInLottieAnimationState extends State<FadeInLottieAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward(); // Start the fade-in animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        height: 140.h,
        width: 140.h,
        child: Lottie.network(
          'https://assets.lottiefiles.com/packages/lf20_xlmz9xwm.json',
          repeat: true,
        ),
      ),
    );
  }
}
