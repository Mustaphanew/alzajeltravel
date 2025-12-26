import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/utils/classes/debouncer.dart';


class AirportSearchController extends GetxController {
  final repo = AirportRepo();
  final textCtrl = TextEditingController();
  final focusNode = FocusNode();
  final debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  final RxString query = ''.obs;
  final RxList<Map<String, dynamic>> results = <Map<String, dynamic>>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // textCtrl.addListener(_onTextChanged);
    onChangeText(textCtrl.text);
  }

  // void _onTextChanged() {
  //   query.value = textCtrl.text;
  //   debouncer.run(() => search(textCtrl.text));
  // }

  onChangeText(String txt) {
    query.value = textCtrl.text;
    debouncer.run(() => search(textCtrl.text));
  }

  Future<void> search(String q) async {
    final trimmed = q.trim();
    // if (trimmed.isEmpty) {
    //   results.clear();
    //   loading.value = false;
    //   error.value = '';
    //   // return;
    // }
    try {
      loading.value = true;
      error.value = '';
      print("trimmed: $trimmed");
      final res = await repo.search(trimmed);
      print("trimmed_2: $trimmed");
      results.assignAll(res);
    } 
    // catch (e) {
    //   error.value = 'حدث خطأ غير متوقع. حاول لاحقًا.';
    //   print("err: $e");
    // } 
    finally {
      loading.value = false;
    }
  }

  void clear() {
    textCtrl.text = "";
    results.clear();
    error.value = '';
    search("");
  }

  @override
  void onClose() {
    // Dispose the text controller to free up memory.
    textCtrl.dispose();
    // Dispose the focus node to free up memory.
    focusNode.dispose();
    // Dispose the debouncer to free up memory.
    debouncer.dispose();
    super.onClose(); // Call the superclass method to complete the disposal.
    super.onClose();
  }
}
