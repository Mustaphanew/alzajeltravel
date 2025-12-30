import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:alzajeltravel/controller/profile/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  final ProfileModel data;
  const ProfilePage({super.key, required this.data});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileController(initialData: widget.data));
  }

  @override
  void dispose() {
    // لو عندك أكثر من ProfilePage ممكن تستخدم tag بدل put العادي
    // هنا ما نحذف controller يدويًا لأن GetX يدير lifecycle غالبًا
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GetBuilder<ProfileController>(
      builder: (c) {
        return Scaffold(
          appBar: AppBar(title: Text('Profile Account'.tr), titleSpacing: 15),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  //  const SizedBox(height: 20),
                  // ProfileBalanceCharts(profile: widget.data),
                  Divider(height: 0, thickness: 2),
                  Form(
                    key: c.formKey,

                    child: ExpansionTile(
                      initiallyExpanded: true,
                      tilePadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      title: Text("Profile".tr),
                      // subtitle: Text("close and reopen all open command prompts", style: TextStyle(color: Colors.grey[600])),
                      childrenPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      children: [
                        const SizedBox(height: 12),

                        // TextFormField(
                        //   controller: c.companyRegistrationNumberController,
                        //   decoration: InputDecoration(
                        //     labelText: 'Company Registration Number'.tr,
                        //     hintText: 'Enter Company Registration Number'.tr,
                        //   ),
                        //   validator: (v) => c.validateRequired(v, 'Company Registration Number Required'),
                        //   textInputAction: TextInputAction.next,
                        // ),
                        // const SizedBox(height: 12),

                        TextFormField(
                          controller: c.nameController,
                          decoration: InputDecoration(labelText: 'Name'.tr, hintText: 'Enter Name'.tr),
                          validator: (v) => c.validateRequired(v, 'Name Required'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: c.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(labelText: 'Email'.tr, hintText: 'Enter Email'.tr),
                          validator: c.validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: c.agencyNumberController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Agency Number'.tr, hintText: 'Enter Agency Number'.tr),
                          validator: (v) => c.validateRequired(v, 'Agency Number Required'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: c.phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(labelText: 'Phone'.tr, hintText: 'Enter Phone'.tr),
                          validator: (v) => c.validateRequired(v, 'Phone Required'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        // Country (readOnly + open picker)
                        // TextFormField(
                        //   controller: c.countryController,
                        //   readOnly: true,
                        //   decoration: InputDecoration(
                        //     labelText: 'Country'.tr,
                        //     hintText: 'Select Country'.tr,
                        //     suffixIcon: const Icon(Icons.arrow_drop_down),
                        //   ),
                        //   onTap: c.pickCountry,
                        //   validator: (v) => c.validateRequired(v, 'Country Required'),
                        // ),
                        // const SizedBox(height: 12),

                        // TextFormField(
                        //   controller: c.addressController,
                        //   decoration: InputDecoration(labelText: 'Address'.tr, hintText: 'Enter Address'.tr),
                        //   textInputAction: TextInputAction.next,
                        // ),
                        // const SizedBox(height: 12),

                        // TextFormField(
                        //   controller: c.websiteController,
                        //   keyboardType: TextInputType.url,
                        //   decoration: InputDecoration(labelText: 'Website'.tr, hintText: 'Enter Website'.tr),
                        //   textInputAction: TextInputAction.next,
                        // ),
                        // const SizedBox(height: 12),
                        // branch code
                        // TextFormField(
                        //   controller: c.branchCodeController,
                        //   decoration: InputDecoration(labelText: 'Branch Code'.tr, hintText: 'Enter Branch Code'.tr),
                        //   readOnly: true,
                        //   textInputAction: TextInputAction.next,
                        // ),
                        const SizedBox(height: 12),

                        // Status (readOnly)
                        TextFormField(
                          controller: c.statusController,
                          readOnly: true,
                          decoration: InputDecoration(labelText: 'Status'.tr, hintText: 'Status'.tr),
                        ),
                        const SizedBox(height: 20),
                        BalanceCard(data: widget.data, context: context),
                        const SizedBox(height: 20),

                        // SizedBox(
                        //   height: 52,
                        //   child: ElevatedButton(
                        //     onPressed: c.isSaving ? null : c.saveProfile,
                        //     child: c.isSaving
                        //         ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        //         : Text('Save'.tr),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}

class BalanceCard extends StatefulWidget {
  const BalanceCard({
    super.key,
    required this.data,
    required this.context,
  });

  final ProfileModel data;
  final BuildContext context;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool showValue = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 8,
          top: 8,
          bottom: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Account Balance'.tr,
                    style: TextStyle(fontSize: AppConsts.normal, fontWeight: FontWeight.normal),
                  ),
                  // const SizedBox(height: 4),
              
                  Text('Remaining Balance'.tr, 
                    style: TextStyle(
                      color: cs.primaryFixed, 
                      fontSize: AppConsts.xlg,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (showValue)
                    Row(
                      children: [
                        SelectableText(
                          AppFuns.priceWithCoin(double.parse(widget.data.remainingBalance.toString()), "USD"), 
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: cs.secondaryFixed,
                            fontSize: AppConsts.xlg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  if (!showValue)
                    Text(
                      '******',
                      style: TextStyle(
                        color: cs.secondaryFixed, 
                        fontWeight: FontWeight.bold,
                        fontSize: AppConsts.xlg, 
                      ),
                    ),
              
              
              
                  // const Divider(height: 16),
              
                  // balanceRow(
                  //   'Used Balance'.tr, 
                  //   fmt(data.usedBalance ?? 0), 
                  //   styleValue: TextStyle(color: cs.error, fontWeight: FontWeight.bold),
                  // ),
              
                  // const Divider(height: 16, thickness: 3),
              
                  // balanceRow(
                  //   'Total Balance'.tr,
                  //   fmt(data.totalBalance ?? 0),
                  //   styleTitle: const TextStyle(fontWeight: FontWeight.bold),
                  //   styleValue: const TextStyle(fontWeight: FontWeight.w900),
                  // ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  showValue = !showValue;
                });
              },
              icon: Icon(
                showValue ? Icons.visibility : Icons.visibility_off,
                color: cs.primaryFixed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
