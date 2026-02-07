import 'package:flutter/material.dart';

class GradientBgContainer extends StatelessWidget {
  const GradientBgContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.borderRadius = BorderRadius.zero,
    this.width,
    this.height,
    this.alignment,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry borderRadius;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerEnd,
          end: AlignmentDirectional.centerStart, // 90deg (left -> right)
          colors: [
            Color.fromRGBO(5, 32, 90, 0.10),
            Color.fromRGBO(245, 175, 34, 0.16),
          ],
        ),
      ),
      child: child,
    );
  }
}
