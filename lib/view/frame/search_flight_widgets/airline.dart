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
    final cs = Theme.of(context).colorScheme;

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
              labelText: 'Included Airlines'.tr,
              labelStyle: TextStyle(fontSize: 12),
              hintText: 'Select Airlines'.tr,
              hintStyle: TextStyle(fontSize: 12),
              border: OutlineInputBorder(),
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
                  label: Text('${e.code} — ${e.name[AppVars.lang]}', style: TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.clear, size: 12),
                  onDeleted: () => controller.removeInclude(e),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            );
          },

          popupProps: PopupPropsMultiSelection.dialog(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search'.tr + ' ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            cacheItems: true,
            disableFilter: false,
            searchDelay: const Duration(milliseconds: 150),
            fit: FlexFit.loose,

            // ❗ تعطيل أي عنصر موجود في "المستبعدة"
            disabledItemFn: (item) => controller.inExclude(item),

            // الهيدر
            title: Material(
              color: cs.primary,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 8, top: 16, bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Airlines Included'.tr,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onPrimary),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: cs.onPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),

            showSelectedItems: true, // ← المهم عشان isSelected يصير true عند الاختيار
            // عنصر القائمة (نبه بصرياً عند التعطيل)
            itemBuilder: (context, item, isDisabled, isSelected) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: isDisabled ? 0.45 : 1,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      leading: Container(width: 60, height: 60, child: CacheImg(AppFuns.airlineImgURL(item.code))),
                      dense: false,
                      tileColor: Colors.transparent,
                      title: Text('${item.name[AppVars.lang]}', overflow: TextOverflow.ellipsis, maxLines: 2),
                      titleAlignment: ListTileTitleAlignment.center,
                      subtitle: Row(
                        children: [
                          CountryFlag.fromCountryCode('${item.countryCode}', theme: ImageTheme(width: 18, height: 12)),
                          SizedBox(width: 8),
                          if (item.note != null)
                            Expanded(
                              child: Text(
                                "${item.note}",
                                style: TextStyle(fontSize: AppConsts.sm),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: isSelected, 
                        onChanged: (v) {}, 
                        fillColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            if(Get.isDarkMode) {
                              return cs.secondary;
                            }
                          }
                        }),
                      ),
                    ),
                  ),
                  const Divider(height: 0),
                ],
              );
            },

            checkBoxBuilder: (context, item, isDisabled, isSelected) {
              return Visibility(visible: true, child: SizedBox.shrink());
            },

            listViewProps: const ListViewProps(shrinkWrap: true, padding: EdgeInsets.zero),

            dialogProps: const DialogProps(
              clipBehavior: Clip.antiAlias,
              insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: OutlineInputBorder(
                borderSide: BorderSide(width: 0),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                gapPadding: 0,
              ),
            ),

            validationBuilder: (context, selected) => Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                boxShadow: [BoxShadow(color: cs.outlineVariant.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, -2))],
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'.tr),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.setInclude(selected);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check),
                    label: Text('OK'.tr),
                  ),
                ],
              ),
            ),
          ),

          suffixProps: const DropdownSuffixProps(
            clearButtonProps: ClearButtonProps(isVisible: true),
          ),
          

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
    final cs = Theme.of(context).colorScheme;

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
              labelText: 'Excluded Airlines'.tr,
              hintText: 'Select Airlines'.tr,
              labelStyle: TextStyle(fontSize: 12),
              hintStyle: TextStyle(fontSize: 12),
              border: OutlineInputBorder(),
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
                  label: Text('${e.code} — ${e.name[AppVars.lang]}', style: TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.clear, size: 12),
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
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search'.tr + ' ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            cacheItems: true,
            disableFilter: false,
            searchDelay: const Duration(milliseconds: 150),
            fit: FlexFit.loose,

            // ❗ تعطيل أي عنصر موجود في "المسموح"
            disabledItemFn: (item) => controller.inInclude(item),

            title: Material(
              color: cs.primary,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 8, top: 16, bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Airlines Excluded'.tr,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onPrimary),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: cs.onPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),

            itemBuilder: (context, item, isDisabled, isSelected) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: isDisabled ? 0.45 : 1,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      leading: Container(width: 60, height: 60, child: CacheImg(AppFuns.airlineImgURL(item.code))),
                      dense: false,
                      tileColor: Colors.transparent,
                      title: Text('${item.name[AppVars.lang]}', overflow: TextOverflow.ellipsis),
                      titleAlignment: ListTileTitleAlignment.center,
                      subtitle: Row(
                        children: [
                          CountryFlag.fromCountryCode('${item.countryCode}', theme: ImageTheme(width: 18, height: 12)),
                          SizedBox(width: 8),
                          if (item.note != null)
                            Expanded(
                              child: Text(
                                "${item.note}",
                                style: TextStyle(fontSize: AppConsts.sm),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                        ],
                      ),

                      trailing: Checkbox(value: isSelected, onChanged: (v) {}),
                    ),
                  ),
                  const Divider(height: 0),
                ],
              );
            },

            checkBoxBuilder: (context, item, isDisabled, isSelected) {
              return const SizedBox.shrink();
            },

            listViewProps: const ListViewProps(shrinkWrap: true),

            dialogProps: const DialogProps(
              clipBehavior: Clip.antiAlias,
              insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: OutlineInputBorder(
                borderSide: BorderSide(width: 0),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                gapPadding: 0,
              ),
            ),

            validationBuilder: (context, selected) => Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                boxShadow: [BoxShadow(color: cs.outlineVariant.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, -2))],
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              ),
              child: Row(
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel'.tr)),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.setExclude(selected);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check),
                    label: Text('OK'.tr),
                  ),
                ],
              ),
            ),
          ),

          suffixProps: const DropdownSuffixProps(
            clearButtonProps: ClearButtonProps(isVisible: true),
          ),
          
          // validator: (vals) => (vals == null || vals.isEmpty) ? 'Please select at least one item' : null,
        );
      },
    );
  }
}
