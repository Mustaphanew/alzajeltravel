// lib/view/common/picker_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final Widget? icon;
  SettingOption({required this.value, required this.label, this.subtitle, this.icon});
}

Future<void> showPickerBottomSheet<T>({
  required BuildContext context,
  required String title,
  required List<SettingOption<T>> options,
  required T selected,
  required void Function(T value) onSelected,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.75, // 👈 نفس القيمة
        maxChildSize: 0.75, // 👈 نفس القيمة (مقفّل)
        builder: (_, scroll) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(3)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          }, 
                          icon: const Icon(Icons.navigate_before),
                        ),
                        Text(title, style: theme.textTheme.titleMedium), 
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                // controller: scroll, 
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final opt = options[i];
                  final isSel = opt.value == selected;
                  return ListTile(
                    tileColor: Colors.transparent,
                    leading: opt.icon,
                    title: Text(opt.label),
                    subtitle: opt.subtitle != null ? Text(opt.subtitle!) : null,
                    trailing: isSel ? const Icon(Icons.check) : null,
                    onTap: () {
                      onSelected(opt.value);
                      Navigator.pop(context);
                    },
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
              ),
            ),
          ],
        ),
      );
    },
  );
}
