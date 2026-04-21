// farings_baggages_table.dart
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class FaringsBaggagesTable extends StatelessWidget {
  const FaringsBaggagesTable({
    super.key,
    required this.context,
    required this.data,
    this.title,
  });

  final BuildContext context;
  final List<Map<String, dynamic>> data;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // لو ما في بيانات نرجّع كرت صغير بسيط
    if (data.isEmpty) {
      return Card(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: cs.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppConsts.secondaryColor.withValues(alpha: 0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('No data'.tr, style: theme.textTheme.bodyMedium),
        ),
      );
    }

    // نأخذ الأعمدة من أول عنصر (Map)
    final columnsKeys = data.first.keys.toList();

    bool isNumericColumn(String key) {
      final k = key.toLowerCase();
      print("key: $k"); 
      return k.contains('weight') ||
          k.contains('price') ||
          k.contains('amount') ||
          k.contains('qty') ||
          k.contains('quantity') ||
          k.contains('fare') ||
          k.contains('total') ||
          k.contains('total fare');
    }

    String labelFromKey(String key) {
      if (key.isEmpty) return key;
      // نضبط أول حرف كابيتال ونترك الباقي مثل ما هو
      return key[0].toUpperCase() + key.substring(1);
    }

    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppConsts.secondaryColor.withValues(alpha: 0.42), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Divider(color: cs.outline.withValues(alpha: 0.4), height: 16, thickness: 0.7),
            ],

            // الجدول نفسه — header بهوية Navy + Gold
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DataTable(
                horizontalMargin: 12,
                columnSpacing: 32,
                headingRowHeight: 40,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 40,
                headingTextStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.secondary,
                  letterSpacing: 0.3,
                ),
                dataTextStyle: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
                headingRowColor: WidgetStateColor.resolveWith((states) => cs.primary),
                dividerThickness: 0.6,
                columns: [
                  for (final key in columnsKeys)
                    DataColumn(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(labelFromKey(key).tr),
                      ),
                      numeric: isNumericColumn(key),
                      headingRowAlignment: MainAxisAlignment.start,
                    ),
                ],
                rows: [
                  for (final row in data)
                    DataRow(
                      cells: [
                        for (final key in columnsKeys)
                          DataCell(
                            Align(
                              alignment: isNumericColumn(key)
                                  ? AlignmentDirectional.centerEnd
                                  : AlignmentDirectional.centerStart,
                              child: Text(
                                '${row[key] ?? ''}',
                                textAlign: isNumericColumn(key) ? TextAlign.end : TextAlign.start,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


