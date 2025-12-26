import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/country_controller.dart';
import 'package:alzajeltravel/model/country_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class CountryPicker extends StatefulWidget {
  final bool? showDialCode;
  const CountryPicker({super.key, this.showDialCode});

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final String lang = AppVars.lang ?? 'en';

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Select country'.tr)),
      body: GetBuilder<CountryController>(
        // ⬅️ هنا ننشئ كنترولر جديد لكل CountryPicker
        init: CountryController(),
        builder: (controller) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  autofocus: true,
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search country or dial code'.tr,
                    hintText: 'Type to search'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    controller.getData(value);
                  },
                ),
              ),
              Expanded(
                child: _buildResultList(
                  controller: controller,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultList({
    required CountryController controller,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    if (controller.isLoading && controller.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<CountryModel> items =
        controller.results.map((e) => CountryModel.fromJson(e)).toList();

    if (items.isEmpty) {
      return Center(child: Text('No results'.tr));
    }

    return CupertinoScrollbar(
      thumbVisibility: true,
      controller: scrollController,
      child: ListView.separated(
        controller: scrollController,
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final country = items[index];

          final displayName = country.name[lang] ?? country.name['en'] ?? '';

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: ListTile(
              leading: CountryFlag.fromCountryCode(
                country.alpha2,
                theme: const ImageTheme(
                  shape: Rectangle(),
                  width: 38,
                  height: 32,
                ),
              ),
              title: Text(displayName),
              subtitle: Text(
                '${country.name['en']}',
                style: TextStyle(
                  fontSize: AppConsts.sm,
                  color: colorScheme.tertiary,
                ),
              ),
              trailing: (widget.showDialCode == null || widget.showDialCode == false)? null : Text(
                "+${country.dialcode}",
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: colorScheme.primaryFixed,
                ),
                textDirection: TextDirection.ltr,
              ),
              onTap: () {
                Get.back<CountryModel>(result: country);
              },
            ),
          );
        },
      ),
    );
  }
}
