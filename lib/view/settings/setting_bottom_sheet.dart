// lib/view/common/picker_bottom_sheet.dart
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:flutter/material.dart';

class SettingOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final Widget? icon;
  SettingOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });
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
  final isDark = theme.brightness == Brightness.dark;
  final isRtl = AppVars.lang == 'ar';

  final Color sheetBg = isDark ? const Color(0xFF0B1228) : Colors.white;
  final Color headerBg = isDark ? const Color(0xFF121A38) : const Color(0xFFFAF6F1);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (_, scroll) => Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(
                color: AppConsts.secondaryColor.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Container(
                decoration: BoxDecoration(
                  color: headerBg,
                  border: Border(
                    bottom: BorderSide(
                      color: AppConsts.secondaryColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color:
                            AppConsts.secondaryColor.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 16, 10),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppConsts.secondaryColor
                                      .withValues(alpha: 0.14),
                                  border: Border.all(
                                    color: AppConsts.secondaryColor
                                        .withValues(alpha: 0.55),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  isRtl
                                      ? Icons.chevron_right_rounded
                                      : Icons.chevron_left_rounded,
                                  color: AppConsts.secondaryColor,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppConsts.secondaryColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppConsts.lg,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Options ──
              Expanded(
                child: ListView.separated(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final opt = options[i];
                    final isSel = opt.value == selected;

                    final Color tileBg = isSel
                        ? AppConsts.secondaryColor
                            .withValues(alpha: isDark ? 0.14 : 0.16)
                        : (isDark
                            ? const Color(0xFF121A38)
                            : Colors.white);
                    final Color tileBorder = isSel
                        ? AppConsts.secondaryColor.withValues(alpha: 0.7)
                        : AppConsts.secondaryColor
                            .withValues(alpha: isDark ? 0.28 : 0.22);

                    return Material(
                      color: tileBg,
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          onSelected(opt.value);
                          Navigator.pop(context);
                        },
                        splashColor:
                            AppConsts.secondaryColor.withValues(alpha: 0.14),
                        highlightColor:
                            AppConsts.secondaryColor.withValues(alpha: 0.06),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: tileBorder,
                              width: isSel ? 1.4 : 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              if (opt.icon != null)
                                Container(
                                  width: 38,
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppConsts.secondaryColor
                                        .withValues(alpha: 0.14),
                                    border: Border.all(
                                      color: AppConsts.secondaryColor
                                          .withValues(alpha: 0.55),
                                      width: 1,
                                    ),
                                  ),
                                  child: IconTheme(
                                    data: const IconThemeData(
                                      color: AppConsts.secondaryColor,
                                      size: 20,
                                    ),
                                    child: opt.icon!,
                                  ),
                                ),
                              if (opt.icon != null) const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.label,
                                      style: TextStyle(
                                        fontSize: AppConsts.normal,
                                        fontWeight: isSel
                                            ? FontWeight.w800
                                            : FontWeight.w700,
                                        color: isSel
                                            ? AppConsts.secondaryColor
                                            : cs.onSurface,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    if (opt.subtitle != null &&
                                        opt.subtitle!.trim().isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        opt.subtitle!,
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
                              const SizedBox(width: 8),
                              if (isSel)
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppConsts.secondaryColor,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: AppConsts.primaryColor,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
