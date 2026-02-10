// passport_form_web.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:alzajeltravel/controller/passport/passport_controller.dart';
import 'package:alzajeltravel/model/country_model.dart';
import 'package:alzajeltravel/model/passport/passport_model.dart'; // Sex
import 'package:alzajeltravel/utils/app_consts.dart';

/// عرض اسم الدولة حسب اللغة
String countryDisplayName(CountryModel? c, String lang) {
  if (c == null) return '';
  final name = c.name;
  if (name is Map) return (name[lang] ?? name['en'] ?? '').toString();
  return name.toString();
}

/// عرض مختصر للدولة داخل أعمدة ضيقة (أفضل كود الدولة)
String countryShort(CountryModel? c) => (c?.alpha2 ?? '').toUpperCase();

class WebTableTextField extends StatelessWidget {
  final double width;
  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final List<TextInputFormatter>? formatters;
  final TextCapitalization caps;
  final bool showLabel;

  const WebTableTextField({
    super.key,
    required this.width,
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.formatters,
    this.caps = TextCapitalization.none,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        autofocus: autofocus,
        inputFormatters: formatters,
        textCapitalization: caps,
        style: const TextStyle(fontSize: AppConsts.normal),
        decoration: InputDecoration(
          isDense: true,
          labelText: showLabel ? label : null,
          labelStyle: const TextStyle(fontSize: 12),
          hintText: showLabel ? null : label,
          hintStyle: TextStyle(color: cs.onSurfaceVariant),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return "${'Please enter'.tr} $label";
          }
          return null;
        },
      ),
    );
  }
}

class WebTableCountryField extends StatelessWidget {
  final double width;
  final String label;
  final String valueShort;
  final String? tooltip;
  final VoidCallback onTap;

  const WebTableCountryField({
    super.key,
    required this.width,
    required this.label,
    required this.valueShort,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final field = SizedBox(
      width: width,
      child: TextFormField(
        // ✅ حل تحديث القيمة بعد الاختيار
        key: ValueKey('$label-$valueShort'),
        readOnly: true,
        onTap: onTap,
        initialValue: valueShort,
        style: const TextStyle(fontSize: AppConsts.normal),
        decoration: InputDecoration(
          isDense: true,
          hintText: label,
          hintStyle: TextStyle(color: cs.onSurfaceVariant),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return "${'Please enter'.tr} $label";
          }
          return null;
        },
      ),
    );

    if ((tooltip ?? '').isEmpty) return field;
    return Tooltip(message: tooltip!, child: field);
  }
}

class WebTableSexField extends StatelessWidget {
  final double width;
  final PassportController controller;

  const WebTableSexField({
    super.key,
    required this.width,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final sex = controller.model.sex;
    final text = sex == null ? '' : sex.label; // M / F

    return SizedBox(
      width: width,
      child: PopupMenuButton<Sex>(
        tooltip: '',
        onSelected: (s) {
          controller.setSex(s);
          // ✅ احتياط: لو setSex ما يعمل update داخليًا
          try {
            controller.update();
          } catch (_) {}
        },
        itemBuilder: (_) => Sex.values
            .map(
              (s) => PopupMenuItem<Sex>(
                value: s,
                child: Text('${s.label} (${s.key.toUpperCase()})'),
              ),
            )
            .toList(),
        child: AbsorbPointer(
          child: TextFormField(
            // ✅ حل عدم تحديث initialValue
            key: ValueKey('sex-$text'),
            readOnly: true,
            initialValue: text,
            style: const TextStyle(fontSize: AppConsts.normal),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Sex'.tr,
              hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: AppConsts.normal),
              // suffixIcon: const Icon(Icons.arrow_drop_down),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (_) => controller.model.sex == null ? 'Please select sex'.tr : null,
          ),
        ),
      ),
    );
  }
}
