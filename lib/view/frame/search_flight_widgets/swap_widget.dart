// swap_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:alzajeltravel/utils/app_consts.dart';

class SwapWidget extends StatelessWidget {
  final bool isSwapped;
  final VoidCallback onTap;

  const SwapWidget({
    super.key,
    required this.isSwapped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: AlignmentDirectional.center,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppConsts.primaryColor, width: 1),
          ),
          child: Icon(
            Icons.swap_horiz,
            size: 28,
          )
              .animate(target: isSwapped ? 1 : 0)
              .rotate(
                begin: isSwapped ? 0 : 0.5,
                end: isSwapped ? 0.5 : 0,
                duration: 400.ms,
                curve: Curves.easeInOut,
              ),
        ),
      ),
    );
  }
}
