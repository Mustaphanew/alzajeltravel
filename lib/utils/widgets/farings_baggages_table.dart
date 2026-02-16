// farings_baggages_table.dart
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
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
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
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Divider(color: cs.outline.withOpacity(0.4), height: 16, thickness: 0.7),
            ],

            // الجدول نفسه
            DataTable(
              horizontalMargin: 0,
              columnSpacing: 32,
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 40,
              headingTextStyle: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
              dataTextStyle: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
              headingRowColor: MaterialStateColor.resolveWith((states) => cs.surface.withOpacity(0.7)),
              columns: [
                for (final key in columnsKeys)
                  DataColumn(
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(labelFromKey(key).tr, style: TextStyle(color: cs.primaryContainer)),
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
            
          ],
        ),
      ),
    ); 
  }
}


