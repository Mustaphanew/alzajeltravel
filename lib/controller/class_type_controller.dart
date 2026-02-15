import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/model/class_type_model.dart';
import 'package:alzajeltravel/repo/class_type_repo.dart';

class ClassTypeController extends GetxController {
  ClassTypeModel? selectedClassType;
  ClassTypeRepo classTypeRepo = ClassTypeRepo();
  TextEditingController txtClassType = TextEditingController();
  List<Map<String, dynamic>> results = [];

  // ✅ القائمة الجاهزة للعرض كأزرار
  final List<ClassTypeModel> classTypes = [];

  Future<void> loadClassTypes() async {
    final resMaps = await classTypeRepo.search(''); // يرجع الكل (بدون بحث)
    classTypes
      ..clear()
      ..addAll(resMaps.map((e) => ClassTypeModel.fromJson(e)));

    // default (اختياري)
    selectedClassType ??= classTypes.isNotEmpty ? classTypes.first : null;

    update();
  }

  Future<List<ClassTypeModel>> getData(String? filter) async {
    final trimmed = filter?.trim() ?? '';
    final res = await classTypeRepo.search(trimmed);
    results.assignAll(res);

    return results.map((e) => ClassTypeModel.fromJson(e)).toList();
  }

  setDefaultClassType() async {
    List<Map<String, dynamic>> classTypes = await classTypeRepo.search('');
    if (classTypes.isNotEmpty) {
      selectedClassType = ClassTypeModel.fromJson(classTypes.first);
    } else {
      selectedClassType = null;
    }
    return selectedClassType;
  }

  changeSelectedClassType(ClassTypeModel? classType) {
    selectedClassType = classType;
    update();
  }

  @override
  void onClose() {
    txtClassType.dispose();
    super.onClose();
  }
} 
