import 'package:flutter/material.dart';

class ResponsiveLayout {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 320) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else if (width < 480) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (width < 768) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
  }

  static double getResponsiveFontSize(BuildContext context, {
    double? baseSize,
    double? smallSize,
    double? largeSize,
  }) {
    final width = getScreenWidth(context);
    final height = getScreenHeight(context);
    
    // Taille de base par défaut
    baseSize ??= 16.0;
    smallSize ??= baseSize * 0.875;
    largeSize ??= baseSize * 1.125;

    // Écrans très petits (iPhone SE, etc.)
    if (width < 320 || height < 568) {
      return smallSize;
    }
    // Écrans petits (iPhone standard)
    else if (width < 375) {
      return baseSize;
    }
    // Écrans moyens (iPhone Plus, Android moyen)
    else if (width < 414) {
      return baseSize;
    }
    // Écrans grands (iPhone Pro Max, Android grand)
    else if (width < 768) {
      return largeSize;
    }
    // Tablettes et plus
    else {
      return largeSize * 1.1;
    }
  }

  static double getResponsiveSpacing(BuildContext context, {
    double? baseSpacing,
    double? smallSpacing,
    double? largeSpacing,
  }) {
    final width = getScreenWidth(context);
    
    baseSpacing ??= 16.0;
    smallSpacing ??= baseSpacing * 0.75;
    largeSpacing ??= baseSpacing * 1.25;

    if (width < 320) {
      return smallSpacing;
    } else if (width < 480) {
      return baseSpacing;
    } else {
      return largeSpacing;
    }
  }

  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final AlignmentGeometry? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
      padding: padding ?? ResponsiveLayout.getResponsivePadding(context),
      alignment: alignment,
      child: child,
    );
  }
} 