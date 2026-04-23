import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  static const List<String> allPermissions = [
    "flight.logout",
    "flight.search",
    "flight.revalidate",
    "flight.other_prices",
    "flight.booking.create",
    "flight.booking.prebook",
    "flight.booking.issue",
    "flight.booking.cancel",
    "flight.booking.void",
    "flight.booking.void_ticket",
    "flight.reports",
    "flight.trip.read",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Set<String> userPerms = (AppVars.profile?.permissions ?? const [])
        .map((e) => e.toString())
        .toSet();

    final Color cardBg = isDark ? const Color(0xFF121A38) : Colors.white;
    final Color borderColor =
        AppConsts.secondaryColor.withValues(alpha: isDark ? 0.35 : 0.28);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppConsts.primaryColor.withValues(
              alpha: isDark ? 0.25 : 0.07,
            ),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppConsts.secondaryColor.withValues(alpha: 0.18)
                  : AppConsts.primaryColor.withValues(alpha: 0.15),
              border: Border.all(
                color: isDark
                    ? AppConsts.secondaryColor.withValues(alpha: 0.55)
                    : AppConsts.primaryColor.withValues(alpha: 0.45),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: isDark
                  ? AppConsts.secondaryColor
                  : AppConsts.primaryColor,
              size: 18,
            ),
          ),
          title: Text(
            "Permissions".tr,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: AppConsts.normal,
              color: cs.onSurface,
              letterSpacing: 0.2,
            ),
          ),
          iconColor: AppConsts.secondaryColor,
          collapsedIconColor: AppConsts.secondaryColor,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),
          tilePadding:
              const EdgeInsetsDirectional.only(start: 14, end: 14),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          children: [
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConsts.secondaryColor.withValues(alpha: 0),
                    AppConsts.secondaryColor.withValues(alpha: 0.45),
                    AppConsts.secondaryColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allPermissions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 1,
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
              itemBuilder: (context, index) {
                final p = allPermissions[index];
                final hasIt = userPerms.contains(p);
                final Color statusColor = hasIt
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFC62828);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor.withValues(alpha: 0.14),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.55),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          hasIt
                              ? CupertinoIcons.checkmark_alt
                              : CupertinoIcons.xmark,
                          color: statusColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
