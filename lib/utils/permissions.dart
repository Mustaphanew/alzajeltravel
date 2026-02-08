
import 'package:alzajeltravel/utils/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Permissions {
  /// Generic helper: checks if the user has a specific permission.
  /// - returns true if found, otherwise false
  static bool hasPermission(List<String> permissions, String permissionKey) {
    // Fast + safe (handles empty list)
    return permissions.contains(permissionKey);
  }

  /// Your requested function
  static bool accessAllowSearch(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.search")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

  // ---- Same idea for all permissions you listed ----

  static bool accessAllowLogout(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.logout")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

  static bool accessAllowRevalidate(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.revalidate")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

  static bool accessAllowOtherPrices(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.other_prices")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

  static bool accessAllowBookingCreate(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.booking.create")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

  static bool accessAllowBookingPrebook(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.booking.prebook")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

  static bool accessAllowBookingIssue(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.booking.issue")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

  static bool accessAllowBookingCancel(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.booking.cancel")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

  static bool accessAllowBookingVoid(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.booking.void")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

  static bool accessAllowBookingVoidTicket(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.booking.void_ticket")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

  static bool accessAllowReports(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.reports")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

  static bool accessAllowTripRead(BuildContext context, List<String> permissions) {
    if (!hasPermission(permissions, "flight.trip.read")) {
      CustomSnackBar.error(
        context, 
        "access denied".tr, 
        subtitle: "Access denied. You don't have the required permission. Please contact the administrator if you need to be granted this permission.".tr,
      );
      return false; 
    }
    return true;
  }

}
