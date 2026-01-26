import 'dart:ui';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'particles_fly.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;

  const GlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: cs.onPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.secondary.withOpacity(0.5), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

