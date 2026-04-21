import 'package:flutter/material.dart';
import 'package:alzajeltravel/utils/app_consts.dart';

class NavChevron extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const NavChevron({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashColor: AppConsts.secondaryColor.withValues(alpha: 0.2),
        highlightColor: AppConsts.secondaryColor.withValues(alpha: 0.1),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? AppConsts.secondaryColor.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: enabled
                  ? AppConsts.secondaryColor.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? AppConsts.secondaryColor
                : Colors.white.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class CloseRoundButton extends StatelessWidget {
  final VoidCallback onTap;

  const CloseRoundButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppConsts.secondaryColor.withValues(alpha: 0.2),
        highlightColor: AppConsts.secondaryColor.withValues(alpha: 0.1),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppConsts.secondaryColor.withValues(alpha: 0.14),
            border: Border.all(
              color: AppConsts.secondaryColor.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 18,
            color: AppConsts.secondaryColor,
          ),
        ),
      ),
    );
  }
}
