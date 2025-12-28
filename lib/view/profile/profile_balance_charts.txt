import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

class ProfileBalanceCharts extends StatefulWidget {
  final ProfileModel profile;
  const ProfileBalanceCharts({super.key, required this.profile});

  @override
  State<ProfileBalanceCharts> createState() => _ProfileBalanceChartsState();
}

class _ProfileBalanceChartsState extends State<ProfileBalanceCharts> {
  final GlobalKey _pieKey = GlobalKey();

  int touchedIndex = -1;
  Offset? tooltipOffsetLocal; // offset داخل مساحة الـ PieChart

  // intl.NumberFormat get _nf => intl.NumberFormat('#,##0.00', 'en_US');
  // String formatBalance(double value) => _nf.format(value);

  String withCurrency(double value) => AppFuns.priceWithCoin(value, "USD");

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final total = (widget.profile.totalBalance ?? 0).toDouble();
    final used = (widget.profile.usedBalance ?? 0).toDouble();

    // remaining داخل المخطط = total - used
    final remainingForChart = (total - used).clamp(0.0, total);

    final usedPercent = total == 0 ? 0.0 : (used / total) * 100.0;
    final remainingPercent = total == 0 ? 0.0 : (remainingForChart / total) * 100.0;

    // بيانات التولتيب بناءً على touchedIndex
    final tooltipTitle = touchedIndex == 0
        ? 'Used Balance'.tr
        : touchedIndex == 1
        ? 'Remaining Balance'.tr
        : '';

    final tooltipValue = touchedIndex == 0
        ? used
        : touchedIndex == 1
        ? remainingForChart
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Account Balance'.tr,
                  style: TextStyle(fontSize: AppConsts.xlg, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 34),

                SizedBox(
                  height: 180,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Pie
                          Container(
                            key: _pieKey,
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: PieChart(
                              PieChartData(
                                centerSpaceRadius: 55,
                                sectionsSpace: 2,
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    // لو لمس خارج الأقسام
                                    final sectionIndex = response?.touchedSection?.touchedSectionIndex ?? -1;

                                    // عند رفع الإصبع/نهاية التفاعل نخفي التأثير
                                    if (event is FlTapUpEvent || event is FlLongPressEnd || event is FlPanEndEvent) {
                                      setState(() {
                                        touchedIndex = -1;
                                        tooltipOffsetLocal = null;
                                      });
                                      return;
                                    }

                                    if (!event.isInterestedForInteractions) return;

                                    // لو ما لمس قسم: نخفي
                                    if (sectionIndex == -1) {
                                      setState(() {
                                        touchedIndex = -1;
                                        tooltipOffsetLocal = null;
                                      });
                                      return;
                                    }

                                    // نحول touchLocation (global) إلى local داخل الـ Pie
                                    final box = _pieKey.currentContext?.findRenderObject() as RenderBox?;
                                    final global = response?.touchLocation;
                                    final local = (box != null && global != null) ? box.globalToLocal(global) : null;

                                    setState(() {
                                      touchedIndex = sectionIndex;
                                      tooltipOffsetLocal = local;
                                    });
                                  },
                                ),
                                sections: [
                                  PieChartSectionData(
                                    value: used,
                                    title: '${usedPercent.toStringAsFixed(1)}%',
                                    radius: touchedIndex == 0 ? 65 : 55, // ✅ يكبر عند الضغط
                                    color: cs.errorContainer,
                                    titleStyle: const TextStyle(color: Colors.white),
                                  ),
                                  PieChartSectionData(
                                    value: remainingForChart,
                                    title: '${remainingPercent.toStringAsFixed(1)}%',
                                    radius: touchedIndex == 1 ? 65 : 55, // ✅ يكبر عند الضغط
                                    color: cs.secondaryFixed,
                                    titleStyle: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Tooltip (Custom)
                          if (tooltipOffsetLocal != null && touchedIndex != -1)
                            _buildTooltip(
                              context: context,
                              constraints: constraints,
                              anchor: tooltipOffsetLocal!,
                              title: tooltipTitle,
                              valueText: withCurrency(tooltipValue),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 34),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _balanceRow('Remaining Balance'.tr, withCurrency(widget.profile.remainingBalance??0), styleValue:  TextStyle(color: cs.secondaryFixed, fontWeight: FontWeight.bold)),
                    const Divider(height: 16),
                    _balanceRow('Used Balance'.tr, withCurrency(widget.profile.usedBalance??0), styleValue: TextStyle(color: cs.error, fontWeight: FontWeight.bold)),
                    const Divider(height: 16, thickness: 3),
                    _balanceRow(
                      'Total Balance'.tr,
                      withCurrency(widget.profile.totalBalance??0),
                      styleTitle: const TextStyle(fontWeight: FontWeight.bold),
                      styleValue: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTooltip({
    required BuildContext context,
    required BoxConstraints constraints,
    required Offset anchor,
    required String title,
    required String valueText,
  }) {
    // أبعاد تقريبية للتولتيب (ثابتة لتسهيل الحساب)
    const tooltipW = 170.0;
    const tooltipH = 64.0;
    const margin = 8.0;

    // نحاول نعرضه فوق نقطة اللمس
    double left = anchor.dx - (tooltipW / 2);
    double top = anchor.dy - tooltipH - 10;

    // منع الخروج خارج الحدود
    left = left.clamp(margin, constraints.maxWidth - tooltipW - margin);
    if (top < margin) {
      // لو ما فيه مساحة فوق، خليه تحت
      top = (anchor.dy + 10).clamp(margin, constraints.maxHeight - tooltipH - margin);
    }

    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: 0.8,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            // width: tooltipW,
            // height: tooltipH,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(valueText, textDirection: TextDirection.ltr),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _balanceRow(String title, String value, {TextStyle? styleTitle, TextStyle? styleValue}) {
    return Row(
      children: [
        Expanded(child: Text(title, style: styleTitle)),
        Text(value, textDirection: TextDirection.ltr, style: styleValue),
      ],
    );
  }
}
