import 'package:flutter/material.dart';

abstract final class AcColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color info = Color(0xFF54A3EB);
  static const Color infoLight = Color(0xFFBADCFC);

  static const Color success = Color(0xFF17B866);
  static const Color successLight = Color(0xFFBBFCBA);

  static const Color primary = Color(0xFFF8C238);
  static const Color secondary = Color(0xFF725E54);
  static const Color subtle = Color(0xFFC3BAAA);
  static const Color card = Color(0xFFFFF5D0);
  static const Color background = Color(0xFF524948);

  static const Color danger = Color(0xFFF47070);
  static const Color dangerLight = Color(0xFFFCBABA);

  static const Color splashColor = Color(0x88FFF5D0);
  static const Color hoverColor = Color(0x44FFF5D0);

  static const Color shadowColor = Color(0x55000000);
}

abstract final class AcSizes {
  // border radius
  static const Radius br = Radius.circular(20.0);
  static const Radius brInput = Radius.circular(10.0);
  static const Radius brCircle = Radius.circular(10000.0);

  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 16.0;
  static const double xl = 32.0;
  static const double xxl = 64.0;

  static const double space = 12.0;

  static const double fontSmall = 12.0;
  static const double fontRegular = 14.0;
  static const double fontEmphasis = 16.0;
  static const double fontLarge = 20.0;
  static const double fontExtraLarge = 28.0;

  static const double iconBig = 28.0;
  static const double avatarRadius = 32.0;
}

abstract final class AcTypography {
  // Don't use these for now, just use Theme.of(context).textTheme
  static const TextStyle bodyMedium = TextStyle(
    fontSize: AcSizes.fontRegular,
    fontWeight: FontWeight.w400,
  );
  static TextStyle bodySmall = bodyMedium.copyWith(fontSize: AcSizes.fontSmall);
  static TextStyle bodyLarge = bodyMedium.copyWith(fontSize: AcSizes.fontLarge);

  static const TextStyle labelMedium = TextStyle(
    fontSize: AcSizes.fontRegular,
    fontWeight: FontWeight.w500,
  );
  static TextStyle largeSmall =
      labelMedium.copyWith(fontSize: AcSizes.fontSmall);
  static TextStyle labelLarge =
      labelMedium.copyWith(fontSize: AcSizes.fontEmphasis);

  static const TextStyle titleMedium = TextStyle(
    fontSize: AcSizes.fontEmphasis,
    fontWeight: FontWeight.bold,
  );
  static TextStyle titleSmall =
      labelMedium.copyWith(fontSize: AcSizes.fontRegular);
  static TextStyle titleLarge =
      labelMedium.copyWith(fontSize: AcSizes.fontLarge);

  static const TextStyle displayMedium = TextStyle(
    fontSize: AcSizes.fontLarge,
    fontWeight: FontWeight.bold,
  );
  static TextStyle displaySmall =
      displayMedium.copyWith(fontSize: AcSizes.fontEmphasis);
  static TextStyle displayLarge =
      displayMedium.copyWith(fontSize: AcSizes.fontExtraLarge);

  // You can use the ones under here
  static const TextStyle placeholder =
      TextStyle(color: Colors.black38, fontSize: AcSizes.fontRegular);

  static const TextStyle importantDescription = TextStyle(
    fontSize: AcSizes.fontEmphasis,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle errorRegular =
      TextStyle(color: AcColors.danger, fontWeight: FontWeight.bold);
}

abstract final class AcDecoration {
  static const BoxShadow shadowRegular = BoxShadow(
      color: AcColors.shadowColor, offset: Offset(0, 2), spreadRadius: 2);
}
