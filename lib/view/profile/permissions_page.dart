import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// تأكد أن AppVars موجودة عندك
// import 'package:alzajeltravel/utils/app_vars.dart';

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
    final cs = Theme.of(context).colorScheme;

    // صلاحيات المستخدم (موجودة في AppVars.profile?.permissions)
    final Set<String> userPerms = (AppVars.profile?.permissions ?? const [])
        .map((e) => e.toString())
        .toSet();

    return Material(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.12),
      // borderRadius: BorderRadius.circular(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), 
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          leading: Icon(
            Icons.verified_user,
            color: Color(0xFF436df4),
          ),
          title: Text(
            "Permissions".tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          collapsedBackgroundColor: cs.surfaceContainerHighest,
          backgroundColor: Color(0xFFe4e4e4),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            side: BorderSide(width: 0, color: cs.outline),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          children: [
            Container(
              color: Theme.of(context).cardTheme.color,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allPermissions.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  final p = allPermissions[index];
                  final hasIt = userPerms.contains(p);
        
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          hasIt ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
                          color: hasIt ? Colors.green : Colors.red,
                          size: 22,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
