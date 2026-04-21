import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.agencyNumber,
    required this.statusText,
    this.isApproved = true,
    this.avatarText = 'NH',
    this.onTap,
  });

  final String name;
  final String email;
  final String agencyNumber;

  /// e.g. "Approved"
  final String statusText;

  /// If you want to switch icon (check / close) and semantic state
  final bool isApproved;

  /// e.g. "NH"
  final String avatarText;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color cardBg = isDark ? const Color(0xFF121A38) : Colors.white;
    final Color borderColor =
        AppConsts.secondaryColor.withValues(alpha: isDark ? 0.35 : 0.28);

    return Material(
      color: cardBg,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        splashColor: AppConsts.secondaryColor.withValues(alpha: 0.12),
        highlightColor: AppConsts.secondaryColor.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppConsts.primaryColor.withValues(
                  alpha: isDark ? 0.30 : 0.08,
                ),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding:
              const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + Status
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppConsts.secondaryColor,
                          AppConsts.secondaryColor.withValues(alpha: 0.85),
                        ],
                      ),
                      border: Border.all(
                        color: AppConsts.primaryColor.withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppConsts.secondaryColor
                              .withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      avatarText,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppConsts.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _StatusChip(
                    text: statusText,
                    isApproved: isApproved,
                  ),
                ],
              ),

              const SizedBox(width: 20),

              // Name + Email + Agency
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.mail_outline_rounded,
                            size: 14,
                            color: AppConsts.secondaryColor
                                .withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppConsts.secondaryColor
                              .withValues(alpha: isDark ? 0.14 : 0.16),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppConsts.secondaryColor
                                .withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.badge_outlined,
                              size: 14,
                              color: AppConsts.secondaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Agency Number".tr,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              agencyNumber,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppConsts.secondaryColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.text,
    required this.isApproved,
  });

  final String text;
  final bool isApproved;

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        isApproved ? const Color(0xFF16A34A) : const Color(0xFFC62828);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.6),
          width: 1,
        ),
        color: statusColor.withValues(alpha: isDark ? 0.16 : 0.14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isApproved
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            text.tr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: statusColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
