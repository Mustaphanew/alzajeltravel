// lib/view/pages/settings_page.dart
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/settings_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/view/settings/help_center.dart';
import 'package:alzajeltravel/view/settings/setting_bottom_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (c) => Scaffold(
        appBar: AppBar(title: Text('App Settings'.tr), titleSpacing: 15,),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: (AppVars.appLocale == Get.deviceLocale)
                        ? const Icon(Icons.language)
                        : CountryFlag.fromLanguageCode(c.locale.languageCode, theme: ImageTheme(height: 24, width: 24, shape: Circle())),
                    title: Text('Language'.tr),
                    subtitle: Text(c.currentLanguage),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      print(" locale: ${c.locale.languageCode}");
                      showPickerBottomSheet<Locale>(
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
                                  ? const Icon(Icons.language)
                                  : CountryFlag.fromLanguageCode(
                                      loc.languageCode,
                                      theme: ImageTheme(height: 28, width: 28, shape: Circle()),
                                    ),
                            );
                          }),
                        ],
                        onSelected: c.setLanguage,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.payments),
                    title: Text('Currency'.tr),
                    subtitle: Text(c.currentCurrency),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showPickerBottomSheet<String>(
                      context: context,
                      title: 'Choose Currency'.tr,
                      selected: c.currency,
                      options: c.currencies.map((e) {
                        final code = e['key'] as String;
                        final label = (e['value'] as String).tr;
                        return SettingOption<String>(value: code, label: label);
                      }).toList(),
                      onSelected: c.setCurrency,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: Text('Appearance'.tr),
                    subtitle: Text(c.currentTheme),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showPickerBottomSheet<ThemeMode>(
                      context: context,
                      title: 'Choose Appearance'.tr,
                      selected: c.themeMode,
                      options: [
                        SettingOption(value: ThemeMode.system, label: 'System'.tr, icon: Icon(Icons.phone_android)),
                        SettingOption(value: ThemeMode.light, label: 'Light'.tr, icon: Icon(Icons.light_mode)),
                        SettingOption(value: ThemeMode.dark, label: 'Dark'.tr, icon: Icon(Icons.dark_mode)),
                      ],
                      onSelected: c.setThemeMode,
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
             
              SizedBox(height: 16),

              HelpCenterPage(title: "Help Center"),
              SizedBox(height: 30),
              // Container(
              //   height: 100, 
              //   width: 100, 
              //   child: SvgPicture.asset(
              //     AppConsts.logoBlack, 
              //     width: 24, 
              //     height: 24,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
