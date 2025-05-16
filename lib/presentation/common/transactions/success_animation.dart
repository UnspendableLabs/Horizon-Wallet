import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class TxnSuccessAnimation extends StatefulWidget {
  const TxnSuccessAnimation({super.key});

  @override
  State<TxnSuccessAnimation> createState() => _TxnSuccessAnimationState();
}

class _TxnSuccessAnimationState extends State<TxnSuccessAnimation> {
  bool _showLottie = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showLottie = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _showLottie
          ? Lottie.asset(
              "assets/lottie/txn_success_anim.json",
              width: 127,
              key: const ValueKey('lottie'),
            )
          : SvgPicture.asset(
              "assets/icons/txn_success_check.svg",
              width: 127,
              key: const ValueKey('svg'),
              colorBlendMode: BlendMode.srcOver,
              fit: BoxFit.contain,
            ),
    );
  }
}