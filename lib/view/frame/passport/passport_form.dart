import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:alzajeltravel/controller/passport/passport_controller.dart';
import 'package:alzajeltravel/controller/passport/passports_forms_controller.dart';
import 'package:alzajeltravel/model/country_model.dart';
import 'package:alzajeltravel/model/passport/passport_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/widgets/country_picker.dart';
import 'package:alzajeltravel/utils/widgets/date_dropdown_row.dart';
import 'package:jiffy/jiffy.dart';

/// ===================================================================
/// PassportFormTile
/// ===================================================================
/// يمثل فورم جواز سفر واحد داخل ExpansionTile:
/// - العنوان فيه: Traveler رقم X + نوعه (Adult/Child/Infant)
/// - يحتوي على الحقول:
///   GIVEN NAMES, SURNAMES, SEX, Date of Birth, Nationality,
///   Document number, Issuing country, Date of expiry
///
/// ملاحظة:
/// - لكل فورم يوجد PassportController مستقل (tag مختلف)
/// - النموذج النهائي يُجمع في PassportsFormsPage عبر controller.model
class PassportFormTile extends StatefulWidget {
  /// tag للـ GetX حتى يكون لكل مسافر كنترولر مستقل
  final String tag;

  final int index;
  /// رقم المسافر (1,2,3,...)
  final int travelerIndex;

  /// النص الذي يمثل نوع المسافر (Adult/Child/Infant) جاهز بالترجمة
  final String ageGroupLabel;

  /// الكنترولر الخاص بالـ ExpansionTile (expand/collapse)
  // final ExpansibleController expansionController;

  /// لغة التطبيق الحالية (لإظهار اسم الدولة بالعربي أو الإنجليزي)
  final String lang;

  /// حالة التوسّع لهذا المسافر
  final bool isExpanded;

  /// أقل تاريخ ميلاد مسموح به لهذا المسافر
  final DateTime minDob;

  /// أكبر تاريخ ميلاد مسموح به لهذا المسافر
  final DateTime maxDob;

  /// كول باك يُستدعى عند تغيير حالة التوسعة
  final ValueChanged<bool> onExpansionChanged;

  /// كول باك عند الضغط على Next (يفتح الفورم التالي)
  /// لو كانت null لا نعرض الزر (مثلاً آخر مسافر)
  final VoidCallback? onNext;
  final VoidCallback? onSave;

  const PassportFormTile({
    super.key,
    required this.index,
    required this.tag,
    required this.travelerIndex,
    required this.ageGroupLabel,
    // required this.expansionController,
    required this.lang,
    required this.isExpanded,
    required this.minDob,
    required this.maxDob,
    required this.onExpansionChanged,
    this.onNext,
    this.onSave,
  });

  @override
  State<PassportFormTile> createState() => _PassportFormTileState();
}

class _PassportFormTileState extends State<PassportFormTile> {

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final textColor = cs.primaryFixed;
    final buttonColor = cs.primaryContainer;

    PassportsFormsController passportsFormsController = Get.find();
    final lastDateInSearch = passportsFormsController.lastDateInSearch;

    return GetBuilder<PassportController>(
      // لكل Passenger tile ننشئ PassportController خاص به
      // init: PassportController(),
      tag: widget.tag,
      builder: (controller) {
        // final txtColor = (Get.isDarkMode) ? Colors.white70 : Colors.grey[800];
        final model = controller.model;
        final passportNo = model.documentNumber;
        final fullName = model.fullName;
        final documentNumber = model.documentNumber;
        final dob = AppFuns.formatDobPretty(model.dateOfBirth);
        final expiryDate = AppFuns.formatDobPretty(model.dateOfExpiry);
        final nationality = model.nationality;
        final issuingCountry = model.issuingCountry;
        final sex = model.sex;

        // bool? lastFullData;
        // final isDone = controller.isFullData;
        // // إذا تغيرت الحالة (من ناقص -> مكتمل أو العكس) نطلب من فورمز كنترولر يعيد build
        // if (lastFullData != isDone) {
        //   lastFullData = isDone;
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     passportsFormsController.refreshOrder();
        //   });
        // }


final isDone = controller.isFullData;
final change = passportsFormsController.recordFullState(widget.tag, isDone);
if (change != 0) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (change == 1) {
      // صار مكتمل الآن -> افتح أول ناقص
      passportsFormsController.openFirstIncomplete();
    } else {
      // صار غير مكتمل الآن (في حالة تعديل بيانات مكتملة) -> فقط إعادة ترتيب
      passportsFormsController.refreshOrder();
    }
  });
}

        final hasGivenNames = model.givenNames?.trim().isNotEmpty ?? false;
        final hasSurnames = model.surnames?.trim().isNotEmpty ?? false;
        final hasDocumentNumber = model.documentNumber?.trim().isNotEmpty ?? false;

        final hasStrData = 
          hasGivenNames && 
          hasSurnames &&
          hasDocumentNumber; 


        return Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 0,
            top: 12,
          ),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListTileTheme(
                data: ListTileThemeData(
                  contentPadding: EdgeInsets.zero,
                  minLeadingWidth: 0,
                  horizontalTitleGap: 0,
                  minTileHeight: 0,
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  isThreeLine: true,
                  minVerticalPadding: 0,
                ),
                child: ExpansionTile(
                  showTrailingIcon: false, 
                  leading: SizedBox(width: 0),
                  key: ValueKey('traveler-${widget.travelerIndex}-${widget.isExpanded}'),
                  iconColor: (Get.isDarkMode) ? cs.secondary : cs.primary,
                  tilePadding: EdgeInsets.only(bottom: 0, top: 0),
                  backgroundColor: Color(0xFFe4e4e4),
                  collapsedBackgroundColor: Colors.transparent,
                  initiallyExpanded: widget.isExpanded,
                  shape: const Border(),
                  splashColor: Colors.transparent,
                  collapsedShape: const Border(),
                  visualDensity: VisualDensity.compact,
                  // enabled: (!controller.isFullData && widget.index == 0),
                  enabled: false, 
                  onExpansionChanged: widget.onExpansionChanged,
                  title: Container(
                    // margin: EdgeInsets.only(bottom: 12, top: 6, left: 8, right: 8),
                    padding: EdgeInsets.only(top: 12, bottom: 16),
                    decoration: (widget.isExpanded == false)? BoxDecoration(
                    // color: cs.onInverseSurface,
                  
                      // borderRadius: BorderRadius.circular(12),
                      
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: cs.outlineVariant.withOpacity(0.9),
                      //     blurRadius: 4,
                      //     offset: const Offset(0, 4), 
                      //   ),
                      // ],
              
              
              
                    ) : null,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Padding(
                            //   padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
                            //   child: Icon(Icons.person, color: textColor),
                            // ),
                            const SizedBox(width: 8),
                            // عنوان المسافر + اسمه إن وُجد
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${'Traveler'.tr} ${widget.travelerIndex}: ${widget.ageGroupLabel}',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConsts.lg, color: textColor),
                                        ),
                                      ),
                                      if (!widget.isExpanded && (controller.isFullData || widget.index == 0))
                                        IconButton(
                                          tooltip: 'Edit'.tr,
                                          onPressed: () {
                                            // passportsFormsController.onTileExpansionChanged(widget.travelerIndex - 1, true);
                                            passportsFormsController.onTileExpansionChangedByTag(widget.tag, true);
                                          },
                                          icon: Icon(
                                            Icons.edit, 
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                    ],
                                  ),
                            
                            
                                  if(widget.isExpanded == false)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                      
                                        if (fullName.isNotEmpty)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2),
                                                child: Icon(
                                                  FontAwesomeIcons.solidUser, 
                                                  color: Color(0xFF438559), 
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 4,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Full name".tr,
                                                    style: TextStyle(
                                                      fontSize: AppConsts.normal,
                                                      color: textColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    fullName,
                                                    style: TextStyle(
                                                      fontSize: AppConsts.normal,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6,),
                                                ],
                                              ),
                                            ],
                                          ),
                                        if (documentNumber != null && documentNumber.isNotEmpty)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 3),
                                                child: Icon(
                                                  FontAwesomeIcons.solidIdCard, 
                                                  color: Color(0xffc74649), 
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 4,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Document number".tr,
                                                    style: TextStyle(
                                                      fontSize: AppConsts.normal,
                                                      color: textColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    documentNumber,
                                                    style: TextStyle(
                                                      fontSize: AppConsts.normal,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                            
                                        if(dob.isNotEmpty) ...[
                                          const SizedBox(height: 6,),
                                          Divider(),
                                          const SizedBox(height: 0,),   
                                        ],
                            
                                        if(dob.isNotEmpty) IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Left column: DOB + Nationality
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 6,),
                                                    if (dob.isNotEmpty)
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Icon(Icons.calendar_month, color: Color(0xffd5632a), size: 20),
                                                          const SizedBox(width: 4),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Date of birth'.tr,
                                                                style: TextStyle(
                                                                  fontSize: AppConsts.normal,
                                                                  color: textColor,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                dob,
                                                                style: TextStyle(
                                                                  fontSize: AppConsts.normal,
                                                                  color: textColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                          
                                                    if (dob.isNotEmpty && nationality != null) const SizedBox(height: 6),
                                          
                                                    if (nationality != null)
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Icon(
                                                            Icons.language, 
                                                            color: Color(0xff436df4), 
                                                            size: 20,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Nationality'.tr,
                                                                style: TextStyle(
                                                                  fontSize: AppConsts.normal,
                                                                  color: textColor,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                children: [
                                                                  Text(
                                                                    nationality.name[widget.lang],
                                                                    style: TextStyle(
                                                                      fontSize: AppConsts.normal,
                                                                      color: textColor,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  CountryFlag.fromCountryCode(
                                                                    nationality.alpha2,
                                                                    theme: (!kIsWeb)? EmojiTheme(size: 16): ImageTheme(height: 16, width: 22),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                          
                                              Expanded(child: const VerticalDivider()),
                                          
                                              // Right column: Expiry + Issuing country
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 6,),
                                                    if (expiryDate.isNotEmpty)
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Icon(Icons.calendar_month, color: Color(0xffd5632a), size: 20),
                                                          const SizedBox(width: 4),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Date of expiry'.tr,
                                                                style: TextStyle(
                                                                  fontSize: AppConsts.normal,
                                                                  color: textColor,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                expiryDate,
                                                                style: TextStyle(
                                                                  fontSize: AppConsts.normal,
                                                                  color: textColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                          
                                                    if (expiryDate.isNotEmpty && issuingCountry != null) const SizedBox(height: 6),
                                          
                                                    if (issuingCountry != null)
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Icon(Icons.language, color: Color(0xff436df4), size: 20),
                                                          const SizedBox(width: 4),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Issuing country'.tr,
                                                                style: TextStyle(
                                                                  fontSize: AppConsts.normal,
                                                                  color: textColor,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                children: [
                                                                  Text(
                                                                    issuingCountry.name[widget.lang],
                                                                    style: TextStyle(
                                                                      fontSize: AppConsts.normal,
                                                                      color: textColor,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  CountryFlag.fromCountryCode(
                                                                    issuingCountry.alpha2,
                                                                    theme: (!kIsWeb)? EmojiTheme(size: 16): ImageTheme(height: 16, width: 22),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                            
                                      ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        
                            // زر مسح بيانات هذا المسافر فقط
                            // InkWell(
                            //   onTap: controller.clearAll,
                            //   child: Container(
                            //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(6),
                            //       border: Border.all(color: cs.error, width: 1),
                            //     ),
                            //     child: Row(
                            //       children: [
                            //         Text('Clear data'.tr, style: const TextStyle(fontSize: AppConsts.sm)),
                            //         const SizedBox(width: 4),
                            //         Icon(Icons.clear_all, color: cs.error, size: 20),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(width: 0),
                        
                            // زر مسح MRZ (يفتح الكاميرا)
                            if (widget.isExpanded)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(end: 12),
                                child: InkWell(
                                  // onTap: () async {
                                  //   // final PassportModel? result = await Get.to<PassportModel>(() => const CameraScanPassport());
                                  //   // if (result != null) {
                                  //   //   controller.applyModel(result);
                                  //   // }
                                  // },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: buttonColor, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Scan'.tr,
                                          style: TextStyle(fontSize: AppConsts.normal, color: buttonColor),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.document_scanner_outlined, color: buttonColor, size: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        
                          ],
                        ),
                    
                      ], 
                    ),
                  ),
                  // childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [      
                    Form(
                      key: controller.formKey,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: cs.onPrimary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            const SizedBox(height: 4),
                                      
                            Row(
                              children: [
                                Icon(CupertinoIcons.person_circle, color: Colors.blue[800]),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(start: 4),
                                  child: Text(
                                    "Traveler data".tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppConsts.lg,
                                    ),
                                  ),
                                ),
                                // Expanded(
                                //   child: Divider(
                                //     thickness: 1,
                                //     indent: 4,
                                //     endIndent: 4,
                                //     color: cs.primaryContainer.withOpacity(0.5),
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                        
                                // GIVEN NAMES
                                Expanded(
                                  flex: 2,
                                  child: _textField(
                                    controller: controller.givenNamesCtr, 
                                    autofocus: true,
                                    formatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9 ]")),
                                        TextInputFormatter.withFunction((oldValue, newValue) {
                                          // منع المسافة في البداية + دمج المسافات المتكررة
                                          final text = newValue.text
                                      .replaceAll(RegExp(r"\s+"), " ")
                                      .replaceFirst(RegExp(r"^ "), "");
                                          return newValue.copyWith(
                                            text: text,
                                            selection: TextSelection.collapsed(offset: text.length),
                                          );
                                        }),
                                      ],
                                    label: 'Given names'.tr + ' (${'traveler'.tr} ${widget.travelerIndex}: ${widget.ageGroupLabel})',
                                  ),
                                ),
                                        
                                const SizedBox(width: 4),
                                        
                                // SURNAMES
                                Expanded(flex: 1, child: _textField(
                                  controller: controller.surnamesCtr, 
                                  label: 'SURNAMES'.tr,
                                  formatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9 ]")),
                                        TextInputFormatter.withFunction((oldValue, newValue) {
                                          // منع المسافة في البداية + دمج المسافات المتكررة
                                          final text = newValue.text
                                      .replaceAll(RegExp(r"\s+"), " ")
                                      .replaceFirst(RegExp(r"^ "), "");
                                          return newValue.copyWith(
                                            text: text,
                                            selection: TextSelection.collapsed(offset: text.length),
                                          );
                                        }),
                                      ],
                                  ),
                                ),
                              ], 
                            ),
                                        
                                        
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
                              child: Text("Date of birth".tr, textAlign: TextAlign.start,),
                            ),
                            IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                        
                                  // Date of Birth باستخدام DateDropdownRow
                                  Expanded(
                                    child: DateDropdownRow(
                                      key: ValueKey('dob-${widget.tag}-${model.dateOfBirth?.toIso8601String() ?? 'empty'}'),
                                      title: SizedBox.shrink(),
                                      initialDate: model.dateOfBirth,
                                      minDate: widget.minDob,
                                      maxDate: widget.maxDob,
                                      onDateChanged: controller.setDateOfBirth,
                                      validator: (date) {
                                        if (date == null) {
                                          return 'Please select a valid date'.tr;
                                        }
                                        if (date.isAfter(DateTime.now())) {
                                          return 'Date of birth cannot be in the future'.tr;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 3),
                                  VerticalDivider(
                                    endIndent: 12,
                                    color: Colors.grey[400],
                                    thickness: 1,
                                  ),
                                  const SizedBox(width: 3),
                                        
                                  
                                  // SEX (M/F)
                                  Container(width: 90, child: _sexDropdown(controller)),
                                ],
                              ),
                            ),
                                        
                            
                            const SizedBox(height: 12),
                            Divider(),
                            const SizedBox(height: 6),
                                        
                            Row(
                              children: [
                                Icon(CupertinoIcons.doc_circle, color: Color(0xffd5632a)),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(start: 4),
                                  child: Text(
                                    "Passport data".tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppConsts.lg,
                                    ),
                                  ),
                                ),
                                // Expanded(
                                //   child: Divider(
                                //     thickness: 1,
                                //     indent: 4,
                                //     endIndent: 4,
                                //     color: cs.primaryContainer.withOpacity(0.5),
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(height: 12),
                                      
                            Row(
                              children: [
                                        
                                // Document number
                                Expanded(
                                  flex: 2,
                                  child: _textField(
                                    controller: controller.documentNumberCtr,
                                    label: 'DOCUMENT NUMBER'.tr,
                                    formatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
                                    caps: TextCapitalization.characters,
                                  ),
                                ),
                                        
                                const SizedBox(width: 4),
                                        
                                // Nationality
                                Expanded(
                                  child: _countryPickerField(
                                    context: context,
                                    label: 'NATIONALITY'.tr,
                                    value: _countryDisplayName(model.nationality),
                                  
                                    onTap: () async {
                                      final CountryModel? picked = await Get.to<CountryModel>(() => const CountryPicker());
                                      if (picked != null) {
                                        controller.setNationality(picked);
                                      }
                                    },
                                  ),
                                ),
                                        
                                const SizedBox(width: 4),
                                        
                                // Issuing country
                                Expanded(
                                  child: _countryPickerField(
                                    context: context,
                                    label: 'ISSUING COUNTRY'.tr,
                                    value: _countryDisplayName(model.issuingCountry),
                                    onTap: () async {
                                      final CountryModel? picked = await Get.to<CountryModel>(() => const CountryPicker());
                                      if (picked != null) {
                                        controller.setIssuingCountry(picked);
                                      }
                                    },
                                  ),
                                ),
                                        
                                        
                              ],
                            ),
                                        
                                      DateDropdownRow(
                                        key: ValueKey(
                                          'expiry-${widget.tag}-${model.dateOfExpiry?.toIso8601String() ?? 'empty'}',
                                        ),
                                        title: Padding(
                                          padding: const EdgeInsetsDirectional.only(bottom: 6, start: 4),
                                          child: Text('DATE OF EXPIRY'.tr),
                                        ), // نفس أسلوب DOB
                                        initialDate: model.dateOfExpiry,
                                      
                                        enabled: hasStrData,
                                      
                                        // أقل تاريخ مسموح = اليوم (حتى ما تختار تاريخ منتهي)
                                        minDate: Jiffy.parseFromDateTime(lastDateInSearch).add(months: 6).dateTime,
                                      
                                        // أقصى تاريخ (عدّلها حسب احتياجك)
                                        maxDate: Jiffy.parseFromDateTime(lastDateInSearch).add(years: 12).dateTime,
                                      
                                        onDateChanged: controller.setDateOfExpiry,
                                      
                                        validator: (date) {
                                          if (date == null) {
                                            return 'Please select a valid date'.tr;
                                          }
                                      
                                          final now = DateTime.now();
                                          final today = DateTime(now.year, now.month, now.day);
                                          final picked = DateTime(date.year, date.month, date.day);
                                      
                                          if (picked.isBefore(today)) {
                                            return 'Passport has already expired'.tr;
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                        
                            // _expiryDateField(
                            //   context: context,
                            //   label: 'DATE OF EXPIRY'.tr,
                            //   value: model.dateOfExpiry,
                            //   onTap: () => controller.pickExpiryDate(context),
                            // ),
                            
                            const SizedBox(height: 8),
                            // زر "Next" للانتقال إلى الفورم التالي (إن وجد)
                            if (widget.onNext != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 4),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // تحقق من صحة هذا الفورم فقط
                                    final formState = controller.formKey.currentState;
                                    if (formState == null) return;
                                        
                                    if (formState.validate()) {
                                      // لو كل شيء صحيح → استدعِ onNext
                                      widget.onNext!();
                                    }
                                  },
                                  icon: Text('Next'.tr),
                                  label: const Icon(Icons.arrow_forward),
                                ),
                              ),
                            if (widget.onNext == null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 4),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // تحقق من صحة هذا الفورم فقط
                                    final formState = controller.formKey.currentState;
                                    if (formState == null) return;
                                        
                                    if (formState.validate()) {
                                      // لو كل شيء صحيح → استدعِ onNext
                                      widget.onSave!();
                                    }
                                  },
                                  icon: Text('Save'.tr),
                                  label: const Icon(Icons.done),
                                ),
                              ),
                                        
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// TextFormField عام مع Validator بسيط (مطلوب)
  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? help,
    int? maxLen,
    bool autofocus = false,
    List<TextInputFormatter>? formatters,
    TextCapitalization caps = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        autofocus: autofocus,
        controller: controller,
        maxLength: maxLen,
        inputFormatters: formatters,
        textCapitalization: caps,
        style: const TextStyle(fontSize: AppConsts.normal),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: AppConsts.normal),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: AppConsts.normal),
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          helperText: help,
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return "${'Please enter'.tr} $label";
          }
          return null;
        },
      ),
    );
  }

  /// Dropdown لاختيار الجنس (M/F)
  Widget _sexDropdown(PassportController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<Sex>(
        initialValue: controller.model.sex,
        iconSize: 0,
        decoration: InputDecoration( 
          contentPadding: EdgeInsetsDirectional.only(start: 8),
          labelText: 'Sex'.tr,
          labelStyle: const TextStyle(fontSize: 12),
          hintStyle: const TextStyle(fontSize: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: Sex.values.map((s) => DropdownMenuItem(
          value: s, 
          child: Text(
            '${s.label} (${s.key.toUpperCase()})',
            style: const TextStyle(fontSize: 14),
          ))).toList(),
        onChanged: controller.setSex,
        validator: (val) {
          if (val == null) {
            return 'Please select sex'.tr;
          }
          return null;
        },
      ),
    );
  }

  /// عرض اسم الدولة الحالي (حسب اللغة)
  String _countryDisplayName(CountryModel? country) {
    if (country == null) return '';
    // نفترض أن country.name هو Map فيه ['en'] و ['ar']
    final dynamic name = country.name;
    if (name is Map) {
      return name[widget.lang] ?? name['en'] ?? '';
    }
    // احتياطاً لو كان CountryModel مختلف
    return name?.toString() ?? '';
  }

  /// حقل عرض دولة مع CountryPicker
  /// حقل دولة باستخدام TextFormField (للدعم الكامل مع validator)
  Widget _countryPickerField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
    // FormFieldValidator<String>? validator,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        /// نستخدم initialValue + key عشان يتحدث الحقل لما تتغير قيمة الدولة
        key: ValueKey('$label-$value'),
        readOnly: true, // المستخدم لا يكتب، فقط يختار من CountryPicker
        onTap: onTap, // عند الضغط نفتح شاشة اختيار الدولة
        initialValue: value, // النص المعروض (اسم الدولة أو فارغ)
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return "${'Please enter'.tr} $label";
          }
          return null;
        },
        // نفس نمط بقية الحقول
        decoration: InputDecoration(
          contentPadding: const EdgeInsetsDirectional.only(start: 8),
          labelText: label,
          hintText: 'Select'.tr + " ...",
          hintStyle: const TextStyle(fontSize: 14),
          labelStyle: const TextStyle(fontSize: 14),
          // suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),

        style: TextStyle(fontSize: 13, color: value.isEmpty ? cs.outline : cs.onSurface),
      ),
    );
  }

  /// حقل لعرض تاريخ الانتهاء مع showDatePicker
  /// حقل تاريخ انتهاء الجواز باستخدام TextFormField
  /// - readOnly: المستخدم لا يكتب يدويًا، يختار من DatePicker
  /// - onTap: يفتح نافذة اختيار التاريخ
  /// - value: القيمة الحالية (تاريخ الانتهاء من الموديل)
  Widget _expiryDateField({required BuildContext context, required String label, required DateTime? value, required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;

    // نحول القيمة إلى نص بصيغة YYYY-MM-DD أو فراغ لو null
    final String textValue = value == null
        ? ''
        : '${value.year.toString().padLeft(4, '0')}-'
              '${value.month.toString().padLeft(2, '0')}-'
              '${value.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        // نستخدم key + initialValue عشان يتحدث الحقل لما تتغير القيمة
        key: ValueKey('expiry-$textValue'),
        readOnly: true,
        onTap: onTap,
        initialValue: textValue,

        decoration: InputDecoration(
          labelText: label,
          hintText: 'Tap to select'.tr,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),

        style: TextStyle(color: textValue.isEmpty ? cs.outline : cs.onSurface),

        // التحقق من صحة الحقل
        validator: (val) {
          // لو ما تم اختيار أي تاريخ
          if (value == null) {
            return 'Please select a valid date'.tr;
          }

          // مثال: لو ما تبي تسمح بجواز منتهي (اختياري)
          // إذا تبي تسمح بالجواز المنتهي، احذف هذا الشرط
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final expiryDate = DateTime(value.year, value.month, value.day);

          if (expiryDate.isBefore(today)) {
            return 'Passport has already expired'.tr;
          }

          return null;
        },
      ),
    );
  }


}
