import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/passport/passports_forms_controller.dart';
import 'package:alzajeltravel/model/contact_model.dart'; // فيه enum ContactTitle

class ContactInformationForm extends StatefulWidget {
  final PassportsFormsController controller;

  const ContactInformationForm({super.key, required this.controller});

  @override
  State<ContactInformationForm> createState() => _ContactInformationFormState();
}

class _ContactInformationFormState extends State<ContactInformationForm> {
  PassportsFormsController get c => widget.controller;

  bool readOnly = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Form(
      key: c.contactFormKey,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Contact information".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // =========================
            //  Title: MR / MISS / MRS
            // =========================
            Text('Title'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTitleButton(context: context, value: ContactTitle.mr, label: 'MR'.tr),
                const SizedBox(width: 8),
                _buildTitleButton(context: context, value: ContactTitle.miss, label: 'MISS'.tr),
                const SizedBox(width: 8),
                _buildTitleButton(context: context, value: ContactTitle.mrs, label: 'MRS'.tr),
              ],
            ),

            const SizedBox(height: 12),

            // FIRST NAME
            TextFormField(
              controller: c.contactFirstNameController,
              decoration: InputDecoration(labelText: 'GIVEN NAMES'.tr, border: const OutlineInputBorder()),
              textInputAction: TextInputAction.next,
              readOnly: readOnly,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter first name'.tr;
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // LAST NAME
            TextFormField(
              readOnly: readOnly,
              controller: c.contactLastNameController,
              decoration: InputDecoration(labelText: 'SURNAMES'.tr, border: const OutlineInputBorder()),
              textInputAction: TextInputAction.next,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter last name'.tr;
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // EMAIL
            TextFormField(
              readOnly: readOnly,
              controller: c.contactEmailController,
              decoration: InputDecoration(labelText: 'Email'.tr, border: const OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter email address'.tr;
                }
                final email = val.trim();
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(email)) {
                  return 'Please enter a valid email address'.tr;
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // CODE
            TextFormField(
              readOnly: readOnly,
              controller: c.contactCodeController,
              decoration: InputDecoration(labelText: 'Code'.tr, border: const OutlineInputBorder()),
              textInputAction: TextInputAction.next,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter code'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // =========================
            //  PHONE + COUNTRY DIAL CODE
            // =========================
            Row(
              children: [
                // حقل رمز البلد (يفتح CountryPicker)
                InkWell(
                  onTap: (readOnly)? null: () async {
                    await c.pickContactDialCountry();
                    setState(() {}); // نحدّث شكل الحقل بعد اختيار الدولة
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: c.contactDialCode == null ? cs.error : cs.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          c.contactDialCode ?? '+',
                          style: TextStyle(fontSize: 16, color: c.contactDialCode == null ? cs.error : cs.onSurface),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // رقم الهاتف
                Expanded(
                  child: TextFormField(
                    readOnly: readOnly,
                    controller: c.contactPhoneController,
                    decoration: InputDecoration(labelText: 'Phone number'.tr, border: const OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter phone number'.tr;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            // رسالة خطأ خاصة برمز البلد
            if (c.contactDialCode == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Please select country dial code'.tr, style: TextStyle(color: cs.error, fontSize: 12)),
              ),

            const SizedBox(height: 12),

            // =========================
            //  Nationality
            // =========================
            Text('Nationality'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: (readOnly)? null: () async {
                await c.pickContactNationalityCountry();
                setState(() {});
              },
              borderRadius: BorderRadius.circular(8),
              child: Container( 
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        c.contactNationalityCountry != null ? (c.contactNationalityCountry!.name[AppVars.lang] ?? '') : 'Select nationality'.tr,
                        style: TextStyle(fontSize: 16, color: c.contactNationalityCountry == null ? cs.outline : cs.onSurface),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleButton({required BuildContext context, required ContactTitle value, required String label}) {
    final cs = Theme.of(context).colorScheme;
    final bool isSelected = c.contactTitle == value;

    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          backgroundColor: isSelected ? cs.primary : Colors.transparent,
          foregroundColor: isSelected ? cs.onPrimary : cs.onSurface,
          disabledForegroundColor: isSelected ? cs.onPrimary : cs.outline,
          side: BorderSide(color: isSelected ? cs.primary : cs.outline, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: (readOnly)? null: () {
          setState(() {
            c.contactTitle = value;
          });
        },
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
