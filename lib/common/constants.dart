import 'package:flutter/widgets.dart';

abstract class AcColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color info = Color(0xFF54A3EB);
  static const Color infoLight = Color(0xFFBADCFC);

  static const Color success = Color(0xFF17B866);
  static const Color successLight = Color(0xFFBBFCBA);

  static const Color primary = Color(0xFFF8C238);
  static const Color secondary = Color(0xFF725E54);
  static const Color subtle = Color(0xFFC3BAAA);
  static const Color surface = Color(0xFFFFF5D0);
  static const Color background = Color(0xFF524948);

  static const Color danger = Color(0xFFF47070);
  static const Color dangerLight = Color(0xFFFCBABA);
}

abstract class AcSizes {
  // border radius
  static const double br = 20.0;
  static const double brInput = 10.0;

  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 16.0;
  static const double xl = 32.0;
  static const double xxl = 64.0;

  static const double fontRegular = 12.0;
  static const double fontEmphasis = 14.0;
  static const double fontBig = 18.0;
}
