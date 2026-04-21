// lib/view/pages/settings_page.dart
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/settings_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/view/settings/help_center.dart';
import 'package:alzajeltravel/view/settings/setting_bottom_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (c) => Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0B1430)
            : const Color(0xFFFAF6F1),
        appBar: AppBar(
          title: Text(
            'App Settings'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: AppConsts.xlg,
              letterSpacing: 0.3,
            ),
          ),
          titleSpacing: 15,
          backgroundColor: AppConsts.primaryColor,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          shape: Border(
            bottom: BorderSide(
              color: AppConsts.secondaryColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───── General section ─────
              _SectionTitle(text: 'App Settings'.tr),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                child: Column(
                  children: [
                    _SettingsRow(
                      leading: (AppVars.appLocale == Get.deviceLocale)
                          ? _iconCircle(
                              child: const Icon(
                                Icons.language_rounded,
                                color: AppConsts.secondaryColor,
                                size: 20,
                              ),
                            )
                          : _iconCircle(
                              padding: 4,
                              child: CountryFlag.fromLanguageCode(
                                c.locale.languageCode,
                                theme: ImageTheme(
                                  height: 26,
                                  width: 26,
                                  shape: Circle(),
                                ),
                              ),
                            ),
                      title: 'Language'.tr,
                      subtitle: c.currentLanguage,
                      onTap: () async {
                        await showPickerBottomSheet<Locale>(
                          context: context,
                          title: 'Choose Language'.tr,
                          selected: c.locale,
                          options: [
                            ...c.languages.map((m) {
                              final loc = m['key'] as Locale;
                              final label = (m['value'] as String).tr;
                              return SettingOption<Locale>(
                                value: loc,
                                label: label,
                                icon: (label == 'System'.tr)
                                    ? const Icon(Icons.language_rounded)
                                    : CountryFlag.fromLanguageCode(
                                        loc.languageCode,
                                        theme: ImageTheme(
                                          height: 28,
                                          width: 28,
                                          shape: Circle(),
                                        ),
                                      ),
                              );
                            }),
                          ],
                          onSelected: c.setLanguage,
                        );
                      },
                    ),
                    _divider(cs),
                    _SettingsRow(
                      leading: _iconCircle(
                        child: const Icon(
                          Icons.brightness_6_rounded,
                          color: AppConsts.secondaryColor,
                          size: 20,
                        ),
                      ),
                      title: 'Appearance'.tr,
                      subtitle: c.currentTheme,
                      onTap: () async {
                        await showPickerBottomSheet<ThemeMode>(
                          context: context,
                          title: 'Choose Appearance'.tr,
                          selected: c.themeMode,
                          options: [
                            SettingOption(
                              value: ThemeMode.system,
                              label: 'System'.tr,
                              icon: const Icon(Icons.phone_android_rounded),
                            ),
                            SettingOption(
                              value: ThemeMode.light,
                              label: 'Light'.tr,
                              icon: const Icon(Icons.light_mode_rounded),
                            ),
                            SettingOption(
                              value: ThemeMode.dark,
                              label: 'Dark'.tr,
                              icon: const Icon(Icons.dark_mode_rounded),
                            ),
                          ],
                          onSelected: c.setThemeMode,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ───── Help center ─────
              _SectionTitle(text: 'Help Center'.tr),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                padding: EdgeInsets.zero,
                child: const HelpCenterPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(ColorScheme cs) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 12,
      endIndent: 12,
      color: cs.outlineVariant.withValues(alpha: 0.4),
    );
  }

  Widget _iconCircle({required Widget child, double padding = 0}) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppConsts.secondaryColor.withValues(alpha: 0.14),
        border: Border.all(
          color: AppConsts.secondaryColor.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, top: 2),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppConsts.secondaryColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: AppConsts.lg,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry padding;

  const _SettingsCard({
    required this.child,
    required this.isDark,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg = isDark ? const Color(0xFF121A38) : Colors.white;
    final Color borderColor =
        AppConsts.secondaryColor.withValues(alpha: isDark ? 0.35 : 0.28);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
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
      padding: padding,
      child: child,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRtl = AppVars.lang == 'ar';

    return InkWell(
      onTap: onTap,
      splashColor: AppConsts.secondaryColor.withValues(alpha: 0.10),
      highlightColor: AppConsts.secondaryColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppConsts.normal,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: AppConsts.sm,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isRtl
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: AppConsts.secondaryColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
