import 'package:flutter/material.dart';

class AppStyle {
  final Color primaryColor = const Color(0xFF005A04);
  final Color secondaryColor = const Color(0xFF2E8F00);
  final Color thirdColor = const Color(0xFF72D49F);
  final Color fourthColor = const Color(0xFF2E8F00);
  final Color fifthColor = const Color(0xFF4E8B6A);
  final Color sixthColor = const Color(0xFFCEF1CD);
  final Color dangerColor = const Color(0xFFB50000);
  final Color dangerColor2 = const Color(0xFFC93648);
  final Color warningColor = const Color(0xFFFFC01F);
  final Color disabledColor = const Color(0xFFABABAB);
  final Color accentColor = const Color(0xFF7BC19C);
  final Color backgroundColor = const Color(0xFFF6FEFF);
  final Color lightColor = const Color(0xFFFFFFFF);
  final Color darkColor = Colors.black;

  ButtonStyle defaultButton() => ButtonStyle(
      backgroundColor:
          MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) return lightColor;
        return primaryColor;
      }),
      foregroundColor:
          MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) return lightColor;
        return lightColor;
      }),
      side: MaterialStateProperty.resolveWith<BorderSide>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return BorderSide(color: accentColor, width: 2);
        }
        return BorderSide(color: accentColor, width: 2);
      }),
      elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) return 0;
        return 2;
      }),
      shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  ButtonStyle customButtonStyle(
      {BorderRadius radiusNormal = const BorderRadius.all(Radius.circular(10)),
      BorderRadius radiusPressed = const BorderRadius.all(Radius.circular(10)),
      BorderSide sideNormal = const BorderSide(color: Colors.grey),
      BorderSide sidePressed = const BorderSide(color: Colors.grey),
      Color bgColorNormal = Colors.white,
      Color fgColorNormal = Colors.black,
      Color bgColorPressed = Colors.grey,
      Color fgColorPressed = Colors.redAccent,
      double elevation = 2,
      Color shadowColorNormal = Colors.black12,
      Color shadowColorPressed = Colors.grey}) {
    return ButtonStyle(backgroundColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) return bgColorPressed;
      return bgColorNormal;
    }), foregroundColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) return fgColorPressed;
      return fgColorNormal;
    }), elevation:
        MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) return 0;
      return elevation;
    }), side: MaterialStateProperty.resolveWith<BorderSide>(
        (Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) return sidePressed;
      return sideNormal;
    }), shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
        (Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return RoundedRectangleBorder(borderRadius: radiusPressed);
      }
      return RoundedRectangleBorder(borderRadius: radiusNormal);
    }), shadowColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return shadowColorPressed.withOpacity(0.2);
      }
      return shadowColorNormal;
    }));
  }

  double textH1 = 26;
  double textH2 = 24;
  double textH3 = 22;
  double textH4 = 20;
  double textH5 = 18;
  double textH6 = 16;
  double textDesc = 14;

  TextStyle typography(
      {double size = 12,
      useDefaultColor = false,
      Color color = Colors.white,
      bool bold = false,
      bool italic = false,
      bool underline = false,
      double? height}) {
    return TextStyle(
        fontSize: size,
        height: height,
        color: useDefaultColor ? null : color,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        fontFamily: "OpenSans",
        decoration: underline ? TextDecoration.underline : TextDecoration.none);
  }
}
