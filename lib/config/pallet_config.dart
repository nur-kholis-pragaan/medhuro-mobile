import 'package:flutter/material.dart';

class PalletConfig {
  static const MaterialColor primaryColor = MaterialColor(
    0xFF6366F1,
    {
      50: Color.fromRGBO(99, 102, 241, .1),
      100: Color.fromRGBO(99, 102, 241, .2),
      200: Color.fromRGBO(99, 102, 241, .3),
      300: Color.fromRGBO(99, 102, 241, .4),
      400: Color.fromRGBO(99, 102, 241, .5),
      500: Color.fromRGBO(99, 102, 241, .6),
      600: Color.fromRGBO(99, 102, 241, .7),
      700: Color.fromRGBO(99, 102, 241, .8),
      800: Color.fromRGBO(99, 102, 241, .9),
      1160: Color.fromRGBO(99, 102, 241, 1),
    },
  );
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color shadePrimaryColor = Color(0xFF374151);
  static const Color shadeSecondary = Color(0xFFF3F4F6);
  static const Color bgColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFFACC15);
  static const padding = 20.0;
  static const borderRadius = 12.0;
  static const fontSmallSize = 12.0;
  static const fontMediumSize = 14.0;
  static const fontLargeSize = 18.0;
}
