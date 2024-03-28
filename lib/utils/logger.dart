import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:truck_monitoring_apps/utils/style.dart';

void printLog(Object obj) {
  if (kDebugMode) {
    print(obj);
  }
}

enum MessageType { warning, danger, success, info, error }

void showMessage(
    {required String title,
    required String message,
    required MessageType type}) {
  AppStyle style = AppStyle();
  Color bgColor = style.primaryColor;
  Color textColor = style.lightColor;
  Icon icon = Icon(Icons.info, color: style.lightColor);
  switch (type) {
    case MessageType.danger:
      {
        bgColor = style.dangerColor;
        textColor = style.lightColor;
        icon = Icon(
          Icons.dangerous_outlined,
          color: style.lightColor,
          size: 36,
        );
        break;
      }
    case MessageType.error:
      {
        bgColor = style.darkColor;
        textColor = style.lightColor;
        icon = Icon(
          Icons.error_outline,
          color: style.lightColor,
          size: 36,
        );
        break;
      }
    case MessageType.success:
      {
        bgColor = style.accentColor;
        textColor = style.lightColor;
        icon = Icon(
          Icons.check_circle_outline,
          color: style.lightColor,
          size: 36,
        );
        break;
      }
    case MessageType.warning:
      {
        bgColor = style.warningColor;
        textColor = style.primaryColor;
        icon = Icon(
          Icons.warning_amber,
          color: style.primaryColor,
          size: 36,
        );
        break;
      }
    default:
      {
        bgColor = style.fifthColor;
        textColor = style.lightColor;
        icon = Icon(
          Icons.info,
          color: style.lightColor,
          size: 36,
        );
        break;
      }
  }
  Get.snackbar(title, message,
      backgroundColor: bgColor.withOpacity(0.8),
      colorText: textColor,
      icon: icon,
      borderRadius: 15,
      leftBarIndicatorColor: style.accentColor,
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.GROUNDED);
}
