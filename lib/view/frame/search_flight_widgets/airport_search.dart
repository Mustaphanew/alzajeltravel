import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:alzajeltravel/controller/airport_search_controller.dart';
import 'package:alzajeltravel/model/airport_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:alzajeltravel/utils/widgets.dart';

class AirportSearch extends StatefulWidget {
  const AirportSearch({super.key});

  @override
  State<AirportSearch> createState() => _AirportSearchState();
}

class _AirportSearchState extends State<AirportSearch> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AirportSearchController());
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color bg = isDark ? const Color(0xFF0B1430) : const Color(0xFFFAF6F1);
    final Color fieldFill = isDark ? const Color(0xFF0E1530) : Colors.white;
    final Color tileBg = isDark ? const Color(0xFF121A38) : Colors.white;
    final Color borderColor =
        AppConsts.secondaryColor.withValues(alpha: isDark ? 0.35 : 0.28);
    final Color focusedBorder =
        AppConsts.secondaryColor.withValues(alpha: 0.9);
    final Color subtitleColor = cs.onSurfaceVariant;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: AppConsts.primaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
          tooltip: 'Back'.tr,
        ),
        title: Text(
          'Search Airport'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppConsts.xlg,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        shape: Border(
          bottom: BorderSide(
            color: AppConsts.secondaryColor.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // ───── Search field ─────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
            child: Obx(
              () => TextField(
                controller: c.textCtrl,
                focusNode: c.focusNode,
                textInputAction: TextInputAction.search,
                onChanged: c.onChangeText,
                autofocus: true,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: AppConsts.normal,
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: AppConsts.secondaryColor,
                decoration: InputDecoration(
                  hintText: 'Search Airport'.tr,
                  hintStyle: TextStyle(
                    color: subtitleColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppConsts.secondaryColor,
                  ),
                  suffixIcon: c.query.value.isEmpty
                      ? null
                      : IconButton(
                          onPressed: c.clear,
                          tooltip: 'Clear'.tr,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppConsts.secondaryColor,
                          ),
                        ),
                  filled: true,
                  fillColor: fieldFill,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: focusedBorder, width: 1.4),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor, width: 1),
                  ),
                ),
              ),
            ),
          ),

          // ───── Results ─────
          Expanded(
            child: Obx(() {
              if (c.error.isNotEmpty) {
                return _ErrorState(
                  message: c.error.value,
                  onRetry: () => c.search(c.query.value),
                );
              }

              if (c.loading.value) {
                return const Center(child: LoadingData());
              }

              if (c.results.isEmpty) {
                return const _EmptyState();
              }

              return CupertinoScrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  itemCount: c.results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final AirportModel item = AirportModel.fromJson(
                      c.results[index],
                    );
                    return _AirportTile(
                      item: item,
                      query: c.query.value,
                      isDark: isDark,
                      tileBg: tileBg,
                      borderColor: borderColor,
                      titleStyle: TextStyle(
                        color: cs.onSurface,
                        fontSize: AppConsts.normal,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                      subtitleStyle: TextStyle(
                        color: subtitleColor,
                        fontSize: AppConsts.sm,
                        fontWeight: FontWeight.w500,
                      ),
                      onTap: () => Get.back(result: item),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AirportTile extends StatelessWidget {
  final AirportModel item;
  final String query;
  final bool isDark;
  final Color tileBg;
  final Color borderColor;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final VoidCallback onTap;

  const _AirportTile({
    required this.item,
    required this.query,
    required this.isDark,
    required this.tileBg,
    required this.borderColor,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAirport = item.type == LocationType.airport;

    return Material(
      color: tileBg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppConsts.secondaryColor.withValues(alpha: 0.14),
        highlightColor: AppConsts.secondaryColor.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Code badge
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppConsts.primaryColor,
                      AppConsts.primaryColor.withValues(alpha: 0.85),
                    ],
                  ),
                  border: Border.all(
                    color: AppConsts.secondaryColor.withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConsts.primaryColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  item.code.length >= 2
                      ? item.code.substring(0, 2).toUpperCase()
                      : item.code.toUpperCase(),
                  style: const TextStyle(
                    color: AppConsts.secondaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: AppConsts.normal,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppConsts.secondaryColor.withValues(
                              alpha: isDark ? 0.14 : 0.18,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppConsts.secondaryColor
                                  .withValues(alpha: 0.55),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            item.code.toUpperCase(),
                            style: const TextStyle(
                              color: AppConsts.secondaryColor,
                              fontSize: AppConsts.sm,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _highlightedText(
                            text: item.name[AppVars.lang] ?? '',
                            query: query,
                            style: titleStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isAirport
                              ? Icons.flight_takeoff_rounded
                              : Icons.location_on_rounded,
                          size: 14,
                          color: AppConsts.secondaryColor
                              .withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _highlightedText(
                            text: item.body[AppVars.lang] ?? '',
                            query: query,
                            style: subtitleStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                AppVars.lang == 'ar'
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: AppConsts.secondaryColor,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// عناصر واجهة لحالات مختلفة
class HintState extends StatelessWidget {
  const HintState({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.travel_explore_rounded,
            size: 56,
            color: AppConsts.secondaryColor.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 12),
          Text(
            'Start typing to search for a city or airport'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppConsts.secondaryColor.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 12),
          Text(
            'No results found'.tr,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: AppConsts.normal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppConsts.secondaryColor.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: AppConsts.normal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppConsts.secondaryColor,
              ),
              label: Text(
                'Retry'.tr,
                style: const TextStyle(
                  color: AppConsts.secondaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppConsts.secondaryColor.withValues(alpha: 0.8),
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// إبراز الجزء المطابق من النص (Highlight)
Widget _highlightedText({
  required String text,
  required String query,
  required TextStyle style,
}) {
  if (query.trim().isEmpty) {
    return Text(
      text,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
  final q = query.trim();
  final lowerText = text.toLowerCase();
  final lowerQ = q.toLowerCase();
  final spans = <TextSpan>[];
  int start = 0;
  while (true) {
    final index = lowerText.indexOf(lowerQ, start);
    if (index < 0) {
      spans.add(TextSpan(text: text.substring(start)));
      break;
    }
    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index)));
    }
    spans.add(
      TextSpan(
        text: text.substring(index, index + q.length),
        style: style.copyWith(
          color: AppConsts.secondaryColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
    start = index + q.length;
    if (start >= text.length) break;
  }
  return Text.rich(
    TextSpan(
      style: (style.fontFamily == null)
          ? style.copyWith(fontFamily: AppConsts.font)
          : style,
      children: spans,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
