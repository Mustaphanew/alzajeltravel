import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class CustomSnackBar {

  static void success(BuildContext context, String title, {String? subtitle, String? detail, bool copy = false}) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: EdgeInsetsDirectional.only(start: 16, end: 0, top: 8, bottom: 8),
        content: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      softWrap: true,
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                ],
              ),
            ),
            if (copy)
              IconButton( 
                style: IconButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () async {
                  await FlutterClipboard.copy('${title}: ${subtitle??''}\n${detail??''}').then((val) {
                    Fluttertoast.showToast(
                      msg: "Copied to clipboard".tr,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                  }).catchError((err) {
                    Fluttertoast.showToast(
                      msg: "Failed to copy to clipboard".tr,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                  }); 
                },
                icon: Icon(Icons.copy_outlined),
              ),
          ],
        ),
        backgroundColor: cs.secondaryFixed,
        duration: Duration(milliseconds: 3000),
        showCloseIcon: true,
      ),
      snackBarAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut,
      ),
    );
  }
  
  static void error(BuildContext context, String title, {String? subtitle, String? detail, bool copy = true}) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: EdgeInsetsDirectional.only(start: 16, end: 0, top: 8, bottom: 8),
        content: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      softWrap: true,
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  if (subtitle == null)
                    Text(
                      AppVars.serverErrMsg,
                      softWrap: true,
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                ],
              ),
            ),
            if (copy)
              IconButton(
                style: IconButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () async {
                  await FlutterClipboard.copy('${title}: ${subtitle??''}\n${detail??AppVars.serverErrResponse}').then((val) {
                    Fluttertoast.showToast(
                      msg: "Copied to clipboard".tr,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                  }).catchError((err) {
                    Fluttertoast.showToast(
                      msg: "Failed to copy to clipboard".tr,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                  }); 
                },
                icon: Icon(Icons.copy_outlined),
              ),
          ],
        ),
        backgroundColor: cs.error,
        duration: Duration(milliseconds: 3000),
        showCloseIcon: true,
      ),
      snackBarAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut,
      ),
    );
  }
  
  static void warning(BuildContext context, String title, {String? subtitle, String? detail, bool copy = true}) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: EdgeInsetsDirectional.only(start: 16, end: 0, top: 8, bottom: 8),
        content: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      softWrap: true,
                      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                ],
              ),
            ),
            if (copy)
              IconButton(
                style: IconButton.styleFrom(foregroundColor: Colors.black),
                onPressed: () async {
                  await FlutterClipboard.copy('${title}: ${subtitle??''}\n${detail??''}').then((val) {
                    Fluttertoast.showToast(
                      msg: "Copied to clipboard".tr,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                  }).catchError((err) {
                    Fluttertoast.showToast(
                      msg: "Failed to copy to clipboard".tr,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                  }); 
                },
                icon: Icon(Icons.copy_outlined),
              ),
          ],
        ),
        backgroundColor: cs.secondary,
        duration: Duration(milliseconds: 3000),
        showCloseIcon: true,
        closeIconColor: Colors.black,
      ),
      snackBarAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut,
      ),
    );
  }

}
