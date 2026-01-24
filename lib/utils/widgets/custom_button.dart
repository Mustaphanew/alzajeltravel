

import 'package:flutter/material.dart';

Gradient customButtonGradient() {
  return LinearGradient(
    colors: [
      Color(0xff0f1a3f), // أغمق
      Color(0xff132057), // اللون الأساسي
      Color(0xff1b2f6f), // أفتح
    ],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );
}

BoxDecoration customButtonDecoration = BoxDecoration(
  gradient: customButtonGradient(),
  borderRadius: BorderRadius.circular(12),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 6,
      offset: const Offset(0, 3),
    ),
  ],
);

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.onPressed, this.icon, required this.label});

  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: customButtonDecoration,
      child: (icon != null)? ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: label,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ): ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: label,
      ),
    );
  }
}

