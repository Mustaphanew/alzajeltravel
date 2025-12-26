import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/model/country_model.dart';
import 'package:alzajeltravel/repo/country_repo.dart';

class CountryController extends GetxController {
  final CountryRepo repo = CountryRepo();

  // text shown in the main form field
  final TextEditingController txt = TextEditingController();

  // search results
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    // load all countries at start
    getData(null);
  }

  Future<void> getData(String? filter) async {
    isLoading = true;
    update();

    final trimmed = filter?.trim() ?? '';
    final res = await repo.search(trimmed);

    results = res;
    isLoading = false;
    update();
  }

  void changeSelected(CountryModel? item) {
    if (item == null) {
      txt.text = '';
    } else {
      // what appears in the TextFormField
      txt.text = '${item.name[AppVars.lang] ?? item.name['en']} (+${item.dialcode})';
    }

    update();
  }
}
