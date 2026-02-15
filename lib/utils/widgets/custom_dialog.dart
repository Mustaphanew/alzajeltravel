import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

class CustomDialog {
  static Future<DismissType?> success(BuildContext context, {required String title, required String desc, String? btnOkText}) async {
    final cs = Theme.of(context).colorScheme;
    final DismissType? dialog = await AwesomeDialog(
      context: context,
      reverseBtnOrder: true,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnOk: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xff00ca71)),
        onPressed: () {
          Navigator.of(context).pop(DismissType.btnOk);
        },
        child: Text(btnOkText ?? 'Ok'.tr), 
      ),
      btnCancel: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: cs.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cs.error),
          ),
        ),
        onPressed: () {
          Navigator.of(context).pop(DismissType.btnCancel);
        },
        child: Text('Close'.tr),
      ),
    ).show();
    return dialog;
  }

  static Future<DismissType?> error(BuildContext context, {required String title, required String desc, String? btnOkText}) async {
    final cs = Theme.of(context).colorScheme;
    final DismissType? dialog = await AwesomeDialog(
      context: context,
      reverseBtnOrder: true,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnOk: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xffd93d46)),
        onPressed: () {
          Navigator.of(context).pop(DismissType.btnOk);
        },
        child: Text(btnOkText ?? 'Ok'.tr), 
      ),
      btnCancel: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: cs.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cs.error),
          ),
        ),
        onPressed: () {
          Navigator.of(context).pop(DismissType.btnCancel);
        },
        child: Text('Close'.tr),
      ),
    ).show();
    return dialog;
  }

  static Future<DismissType?> warning(BuildContext context, {required String title, required String? desc, String? btnOkText}) async {
    final cs = Theme.of(context).colorScheme;
    final DismissType? dialog = await AwesomeDialog(
      context: context,
      reverseBtnOrder: true,
      dialogBackgroundColor: cs.onTertiary,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: title,
      titleTextStyle: TextStyle(
        fontFamily: AppConsts.font,
        fontSize: 22,
      ),
      desc: desc,
      // btnOk: ElevatedButton(
      //   style: ElevatedButton.styleFrom(backgroundColor: Color(0xfffeb800)),
      //   onPressed: () {
      //     Navigator.of(context).pop(DismissType.btnOk);
      //   },
      //   child: Text(
      //     btnOkText ?? 'Ok'.tr,
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ), 
      // ),
      btnCancel: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[800]!),
          ),
        ),
        onPressed: () {
          Navigator.of(context).pop(DismissType.btnCancel);
        },
        label: Text('Close'.tr),
        icon: Icon(Icons.close),
      ),
    ).show();
    return dialog;
  }
}
