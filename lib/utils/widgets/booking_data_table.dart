import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingDataTable extends StatefulWidget {
  const BookingDataTable({
    super.key,
    required this.pnr,
    required this.bookingNumber,
    required this.createdAt, // should contain \n between date and time
    this.voidOn, // should contain \n between date and time
    this.cancelOn, // should contain \n between date and time
    this.title,
  });

  final String pnr;
  final String bookingNumber;
  final String createdAt;
  final String? voidOn;
  final String? cancelOn;
  final String? title;

  @override
  State<BookingDataTable> createState() => _BookingDataTableState();
}

class _BookingDataTableState extends State<BookingDataTable> {
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

    final cols = <_Col>[
      _Col(
        key: "PNR".tr,
        value: (widget.pnr.isNotEmpty ? widget.pnr : "N/A".tr),
        isDateTime: false,
      ),
      _Col(
        key: "Booking Number".tr,
        value: widget.bookingNumber,
        isDateTime: false,
      ),
      _Col(
        key: "Created At".tr,
        value: widget.createdAt,
        isDateTime: true,
      ),
    ];

    if (widget.voidOn != null) {
      cols.add(_Col(key: "Void On".tr, value: widget.voidOn!, isDateTime: true));
    } else if (widget.cancelOn != null) {
      cols.add(_Col(key: "Cancel On".tr, value: widget.cancelOn!, isDateTime: true));
    }

    final columnWidths = <int, TableColumnWidth>{
      for (var i = 0; i < cols.length; i++) i: const IntrinsicColumnWidth(),
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
                        // Header row (one line)
                        TableRow(
                          decoration: BoxDecoration(color: cs.surface.withOpacity(0.7)),
                          children: [
                            for (var i = 0; i < cols.length; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Align(
                                  alignment: _cellAlignment(i, cols.length),
                                  child: Text(
                                    cols[i].key,
                                    textAlign: _textAlign(i, cols.length),
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

                        // Data row (one line except datetime)
                        TableRow(
                          decoration: BoxDecoration(color: cs.surfaceContainer),
                          children: [
                            for (var i = 0; i < cols.length; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Align(
                                  alignment: _cellAlignment(i, cols.length),
                                  child: Text(
                                    cols[i].value,
                                    textAlign: _textAlign(i, cols.length),
                                    softWrap: cols[i].isDateTime,
                                    maxLines: cols[i].isDateTime ? null : 1,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ),
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
}

class _Col {
  _Col({
    required this.key,
    required this.value,
    required this.isDateTime,
  });

  final String key;
  final String value;
  final bool isDateTime;
}
