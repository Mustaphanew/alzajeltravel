import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TravelersDataTable extends StatefulWidget {
  const TravelersDataTable({
    super.key,
    required this.rows,
    this.title,
  });

  final List<Map<String, String>> rows;
  final String? title;

  @override
  State<TravelersDataTable> createState() => _TravelersDataTableState();
}

class _TravelersDataTableState extends State<TravelersDataTable> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  AlignmentDirectional _cellAlignment(int index, int total) {
    if (index == 0) return AlignmentDirectional.centerStart;
    if (index == total - 1) return AlignmentDirectional.centerEnd;
    return AlignmentDirectional.center;
  }

  TextAlign _textAlign(int index, int total) {
    if (index == 0) return TextAlign.start;
    if (index == total - 1) return TextAlign.end;
    return TextAlign.center;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // نفس ترتيب الأعمدة دائمًا
final colTitles = <String>[
  "Full Name".tr,
  "Date of Birth".tr,
  "Sex".tr,
  "Passport Number".tr,
  "Nationality".tr,
  "Issuing Country".tr,
  "Date of Expiry".tr,
  "Ticket".tr,
];

    // نفس فكرة BookingDataTable
final columnWidths = <int, TableColumnWidth>{
  for (var i = 0; i < colTitles.length; i++) i: const IntrinsicColumnWidth(),
};

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.title != null) ...[
                Text(
                  widget.title!.tr,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Divider(color: cs.outline.withOpacity(0.4), height: 16, thickness: 0.7),
              ],

              CupertinoScrollbar(
                thumbVisibility: true,
                controller: scrollController,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 16),
                  controller: scrollController,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Table(
                      columnWidths: columnWidths,
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      border: TableBorder(
                        horizontalInside: BorderSide(color: cs.outlineVariant),
                      ),
                      children: [
                        // Header row
                        TableRow(
                          decoration: BoxDecoration(color: cs.surface.withOpacity(0.7)),
                          children: [
                            for (var i = 0; i < colTitles.length; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Align(
                                  alignment: _cellAlignment(i, colTitles.length),
                                  child: Text(
                                    colTitles[i],
                                    textAlign: _textAlign(i, colTitles.length),
                                    softWrap: false,
                                    maxLines: 1,
                                    overflow: TextOverflow.visible,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Data rows
for (final r in widget.rows)
  TableRow(
    decoration: BoxDecoration(color: cs.surfaceContainer),
    children: [
      _cell(r["full_name"] ?? "", 0, colTitles.length),
      _cell(r["dob"] ?? "", 1, colTitles.length),
      _cell(r["sex"] ?? "", 2, colTitles.length),
      _cell(r["passport_number"] ?? "", 3, colTitles.length),
      _cell(r["nationality"] ?? "", 4, colTitles.length),
      _cell(r["issuing_country"] ?? "", 5, colTitles.length),
      _cell(r["date_of_expiry"] ?? "", 6, colTitles.length),
      _cell(r["ticket"] ?? "", 7, colTitles.length),
    ],
  ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(String text, int index, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Align(
        alignment: _cellAlignment(index, total),
        child: Text(
          text,
          textAlign: _textAlign(index, total),
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }
}
