// lib/view/pages/help_center_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/help_center_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/widgets.dart';

class HelpCenterPage extends StatefulWidget {
  final String? title;
  const HelpCenterPage({super.key, this.title });

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  HelpCenterController helpCenterController = Get.put(HelpCenterController());

  /// يُعيد (iconData, brandColor) لكل خدمة اعتمادًا على رابطها، مع الحفاظ
  /// على الهوية الأصلية (أخضر واتساب، أزرق تلجرام، …).
  ({IconData icon, Color color}) _brandFor(String url) {
    if (url.contains('whatsapp')) {
      return (icon: FontAwesomeIcons.whatsapp, color: const Color(0xFF25D366));
    }
    if (url.contains('t.me')) {
      return (icon: FontAwesomeIcons.telegram, color: const Color(0xFF229ED9));
    }
    if (url.startsWith('tel:')) {
      return (icon: FontAwesomeIcons.phone, color: const Color(0xFF34A853));
    }
    if (url.startsWith('sms:')) {
      return (icon: FontAwesomeIcons.commentSms, color: const Color(0xFF3478F6));
    }
    if (url.startsWith('mailto:')) {
      return (icon: FontAwesomeIcons.envelope, color: const Color(0xFFEA4335));
    }
    if (url == AppConsts.baseUrl) {
      return (icon: FontAwesomeIcons.globe, color: AppConsts.secondaryColor);
    }
    return (icon: FontAwesomeIcons.circleQuestion, color: AppConsts.primaryColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GetBuilder<HelpCenterController>(
      builder: (c) {
        if (c.loading) {
          return LoadingData();
        } else if (c.items == null) {
          return ErrorData();
        } else if (c.items!.isEmpty) {
          return EmptyData();
        }
        return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 12),
                  child: Text(
                    widget.title!.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: c.items!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (_, i) {
                  final item = c.items![i];
                  final brand = _brandFor(item.url.toString());

                  return Material(
                    color: isDark
                        ? const Color(0xFF0E1530)
                        : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => c.openItem(item),
                      splashColor: brand.color.withValues(alpha: 0.12),
                      highlightColor: brand.color.withValues(alpha: 0.06),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppConsts.secondaryColor
                                .withValues(alpha: isDark ? 0.28 : 0.22),
                            width: 1,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              brand.color.withValues(alpha: isDark ? 0.10 : 0.06),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // أيقونة دائرية بلون العلامة + أيقونة بيضاء
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      brand.color,
                                      brand.color.withValues(alpha: 0.78),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: brand.color.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  brand.icon,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.name.tr,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
