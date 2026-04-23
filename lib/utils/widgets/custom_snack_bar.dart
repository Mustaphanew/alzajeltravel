import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:flutter/material.dart';

/// Legacy API preserved for backward compatibility.
///
/// Internally delegates to [AppFuns.showSnack] so that *all* snackbars across
/// the app share the same modern, top-positioned, theme-aware look & feel
/// (navy / gold accents, Almaria font, rounded corners, adaptive light/dark).
///
/// The previous [copy] parameter is intentionally ignored – the new snackbar
/// already places the full message in a way the user can long-press/copy,
/// and the unified design avoids action-button clutter.
class CustomSnackBar {
  static void success(
    BuildContext context,
    String title, {
    String? subtitle,
    String? detail,
    bool copy = false,
  }) {
    AppFuns.showSnack(
      title,
      _composeMessage(subtitle, detail),
      type: SnackType.success,
    );
  }

  static void error(
    BuildContext context,
    String title, {
    String? subtitle,
    String? detail,
    bool copy = true,
  }) {
    AppFuns.showSnack(
      title,
      _composeMessage(subtitle, detail),
      type: SnackType.error,
    );
  }

  static void warning(
    BuildContext context,
    String title, {
    String? subtitle,
    String? detail,
    bool copy = true,
  }) {
    AppFuns.showSnack(
      title,
      _composeMessage(subtitle, detail),
      type: SnackType.warning,
    );
  }

  static String _composeMessage(String? subtitle, String? detail) {
    final parts = <String>[
      if (subtitle != null && subtitle.trim().isNotEmpty) subtitle.trim(),
      if (detail != null && detail.trim().isNotEmpty) detail.trim(),
    ];
    return parts.join('\n');
  }
}
