import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/airline_controller.dart';
import 'package:alzajeltravel/model/airline_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:country_flags/country_flags.dart';

class AirlineIncludeDropDown extends StatelessWidget {
  const AirlineIncludeDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AirlineController>(
      builder: (controller) {
        return DropdownSearch<AirlineModel>.multiSelection(
        
          items: (String? filter, LoadProps? _) => controller.getData(filter),

          filterFn: (item, filter) {
            final q = filter.toLowerCase().trim();
            return item.name['en'].toString().toLowerCase().contains(q) ||
                item.name['ar'].toString().toLowerCase().contains(q) ||
                item.code.toLowerCase().contains(q) ||
                item.countryCode.toLowerCase().contains(q) ||
                (item.note?.toLowerCase().contains(q) ?? false);
          },

          itemAsString: (item) => "${item.code} — ${item.name[AppVars.lang]}",
          compareFn: (a, b) => a.id == b.id,

          selectedItems: controller.includeItems,
          onChanged: (values) => controller.setInclude(values),

          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              contentPadding: const EdgeInsetsDirectional.only(start: 4, end: 4, top: 12, bottom: 12),
              labelText: 'Included Airlines'.tr,
              hintText: 'Select Airlines'.tr,
              prefixIcon: const Icon(
                Icons.airlines_rounded,
                color: AppConsts.secondaryColor,
                size: 20,
              ),
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          // Chips مع زر ×
          dropdownBuilder: (context, List<AirlineModel> selected) {
            if (selected.isEmpty) return const SizedBox.shrink();
            return Wrap(
              spacing: 4,
              runSpacing: 4,
              children: selected.map((e) {
                return InputChip(
                  label: Text(
                    e.code,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppConsts.secondaryColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  backgroundColor:
                      AppConsts.secondaryColor.withValues(alpha: 0.12),
                  side: BorderSide(
                    color: AppConsts.secondaryColor.withValues(alpha: 0.55),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  deleteIcon: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppConsts.secondaryColor,
                  ),
                  onDeleted: () => controller.removeInclude(e),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            );
          },

          popupProps: PopupPropsMultiSelection.dialog(
            showSearchBox: true,
            searchFieldProps: _airlineSearchFieldProps(context),
            cacheItems: true,
            disableFilter: false,
            searchDelay: const Duration(milliseconds: 150),
            fit: FlexFit.loose,

            // ❗ تعطيل أي عنصر موجود في "المستبعدة"
            disabledItemFn: (item) => controller.inExclude(item),

            // الهيدر
            title: _AirlineDialogTitle(text: 'Included Airlines'.tr),

            showSelectedItems: true,
            containerBuilder: (context, child) =>
                _AirlineDialogContainer(child: child),
            itemBuilder: (context, item, isDisabled, isSelected) =>
                _AirlineListItem(
              item: item,
              isDisabled: isDisabled,
              isSelected: isSelected,
            ),

            checkBoxBuilder: (context, item, isDisabled, isSelected) {
              return const SizedBox.shrink();
            },

            listViewProps: const ListViewProps(
                shrinkWrap: true, padding: EdgeInsets.zero),

            dialogProps: _airlineDialogProps(context),

            validationBuilder: (context, selected) => _AirlineDialogActions(
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () {
                controller.setInclude(selected);
                Navigator.of(context).pop();
              },
            ),
          ),

          // suffixProps: const DropdownSuffixProps(
          //   clearButtonProps: ClearButtonProps(isVisible: true),
          // ),
          

          // validator: (vals) => (vals == null || vals.isEmpty) ? 'Please select at least one item' : null,
        );
      },
    );
  }
}

class AirlineExcludeDropDown extends StatelessWidget {
  const AirlineExcludeDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AirlineController>(
      builder: (controller) {
        return DropdownSearch<AirlineModel>.multiSelection(
          items: (String? filter, LoadProps? _) => controller.getData(filter),

          filterFn: (item, filter) {
            final q = filter.toLowerCase().trim();
            return item.name['en'].toString().toLowerCase().contains(q) ||
                item.name['ar'].toString().toLowerCase().contains(q) ||
                item.code.toLowerCase().contains(q) ||
                item.countryCode.toLowerCase().contains(q) ||
                (item.note?.toLowerCase().contains(q) ?? false);
          },

          itemAsString: (item) => '${item.code} — ${item.name[AppVars.lang]}',
          compareFn: (a, b) => a.id == b.id,

          selectedItems: controller.excludeItems,
          onChanged: (values) => controller.setExclude(values),

          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              contentPadding: const EdgeInsetsDirectional.only(start: 4, end: 4, top: 12, bottom: 12),
              labelText: 'Excluded Airlines'.tr,
              hintText: 'Select Airlines'.tr,
              prefixIcon: const Icon(
                Icons.airline_stops_rounded,
                color: AppConsts.secondaryColor,
                size: 20,
              ),
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          dropdownBuilder: (context, List<AirlineModel> selected) {
            if (selected.isEmpty) return const SizedBox.shrink();
            return Wrap(
              spacing: 4,
              runSpacing: 4,
              children: selected.map((e) {
                return InputChip(
                  label: Text(
                    e.code,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppConsts.secondaryColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  backgroundColor:
                      AppConsts.secondaryColor.withValues(alpha: 0.12),
                  side: BorderSide(
                    color: AppConsts.secondaryColor.withValues(alpha: 0.55),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  deleteIcon: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppConsts.secondaryColor,
                  ),
                  onDeleted: () => controller.removeExclude(e),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            );
          },

          popupProps: PopupPropsMultiSelection.dialog(
            showSearchBox: true,
            showSelectedItems: true,
            searchFieldProps: _airlineSearchFieldProps(context),
            cacheItems: true,
            disableFilter: false,
            searchDelay: const Duration(milliseconds: 150),
            fit: FlexFit.loose,

            // ❗ تعطيل أي عنصر موجود في "المسموح"
            disabledItemFn: (item) => controller.inInclude(item),

            title: _AirlineDialogTitle(text: 'Airlines Excluded'.tr),

            containerBuilder: (context, child) =>
                _AirlineDialogContainer(child: child),
            itemBuilder: (context, item, isDisabled, isSelected) =>
                _AirlineListItem(
              item: item,
              isDisabled: isDisabled,
              isSelected: isSelected,
            ),

            checkBoxBuilder: (context, item, isDisabled, isSelected) {
              return const SizedBox.shrink();
            },

            listViewProps: const ListViewProps(shrinkWrap: true),

            dialogProps: _airlineDialogProps(context),

            validationBuilder: (context, selected) => _AirlineDialogActions(
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () {
                controller.setExclude(selected);
                Navigator.of(context).pop();
              },
            ),
          ),

          // suffixProps: const DropdownSuffixProps(
          //   clearButtonProps: ClearButtonProps(isVisible: true),
          // ),
          
          // validator: (vals) => (vals == null || vals.isEmpty) ? 'Please select at least one item' : null,
        );
      },
    );
  }
}

// ================================================================
// Airline dialog helpers — shared navy/gold styling for both
// Include & Exclude airline pickers, in light and dark themes.
// ================================================================

DialogProps _airlineDialogProps(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return DialogProps(
    clipBehavior: Clip.antiAlias,
    insetPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    backgroundColor:
        isDark ? const Color(0xFF0B1430) : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(
        color: AppConsts.secondaryColor.withValues(alpha: 0.45),
        width: 1,
      ),
    ),
  );
}

TextFieldProps _airlineSearchFieldProps(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return TextFieldProps(
    cursorColor: AppConsts.secondaryColor,
    style: TextStyle(
      color: isDark ? Colors.white : AppConsts.primaryColor,
      fontWeight: FontWeight.w600,
    ),
    decoration: InputDecoration(
      hintText: '${'Search'.tr} ...',
      hintStyle: TextStyle(
        color: isDark
            ? Colors.white.withValues(alpha: 0.5)
            : AppConsts.primaryColor.withValues(alpha: 0.45),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: const Icon(
        Icons.search_rounded,
        color: AppConsts.secondaryColor,
        size: 20,
      ),
      filled: true,
      fillColor: isDark
          ? const Color(0xFF0E1530)
          : Colors.white,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppConsts.secondaryColor.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppConsts.secondaryColor.withValues(alpha: 0.9),
          width: 1.4,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

class _AirlineDialogContainer extends StatelessWidget {
  final Widget child;
  const _AirlineDialogContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF0B1430) : Colors.white,
      child: child,
    );
  }
}

class _AirlineDialogTitle extends StatelessWidget {
  final String text;
  const _AirlineDialogTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppConsts.primaryColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppConsts.secondaryColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsetsDirectional.only(
            start: 16, end: 8, top: 14, bottom: 14),
        child: Row(
          children: [
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
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppConsts.secondaryColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AirlineListItem extends StatelessWidget {
  final AirlineModel item;
  final bool isDisabled;
  final bool isSelected;

  const _AirlineListItem({
    required this.item,
    required this.isDisabled,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final Color tileBg = isSelected
        ? AppConsts.secondaryColor.withValues(alpha: isDark ? 0.1 : 0.12)
        : Colors.transparent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: isDisabled ? 0.45 : 1,
          child: Container(
            color: tileBg,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppConsts.primaryColor.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        AppConsts.secondaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: CacheImg(AppFuns.airlineImgURL(item.code)),
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      '${item.name[AppVars.lang]}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: AppConsts.normal,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppConsts.secondaryColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            AppConsts.secondaryColor.withValues(alpha: 0.55),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item.code,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppConsts.secondaryColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    CountryFlag.fromCountryCode(
                      '${item.countryCode}',
                      theme: const ImageTheme(width: 18, height: 12),
                    ),
                    const SizedBox(width: 8),
                    if (item.note != null)
                      Expanded(
                        child: Text(
                          '${item.note}',
                          style: TextStyle(
                            fontSize: AppConsts.sm,
                            color: cs.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                  ],
                ),
              ),
              trailing: _AirlineCheckbox(isSelected: isSelected),
            ),
          ),
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: AppConsts.secondaryColor.withValues(alpha: 0.12),
        ),
      ],
    );
  }
}

class _AirlineCheckbox extends StatelessWidget {
  final bool isSelected;
  const _AirlineCheckbox({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected
            ? AppConsts.secondaryColor
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppConsts.secondaryColor.withValues(
              alpha: isSelected ? 1 : 0.55),
          width: 1.4,
        ),
      ),
      child: isSelected
          ? const Icon(
              Icons.check_rounded,
              size: 16,
              color: AppConsts.primaryColor,
            )
          : null,
    );
  }
}

class _AirlineDialogActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _AirlineDialogActions({
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E1530) : const Color(0xFFFAF6F1),
        border: Border(
          top: BorderSide(
            color: AppConsts.secondaryColor.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppConsts.secondaryColor,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: Text('Cancel'.tr),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConsts.primaryColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppConsts.secondaryColor.withValues(alpha: 0.7),
                  width: 1.2,
                ),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            icon: const Icon(
              Icons.check_circle_rounded,
              color: AppConsts.secondaryColor,
              size: 18,
            ),
            label: Text('OK'.tr),
          ),
        ],
      ),
    );
  }
}
