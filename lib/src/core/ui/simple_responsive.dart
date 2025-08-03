import 'package:flutter/material.dart';

class SimpleResponsive {
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Ratio simple basé sur la largeur de l'écran
  static double getResponsiveValue(BuildContext context, {
    required double baseValue,
    double? smallRatio = 0.8,
    double? largeRatio = 1.2,
  }) {
    final width = getScreenWidth(context);
    
    // Écrans très petits (iPhone SE, etc.)
    if (width < 375) {
      return baseValue * (smallRatio ?? 0.8);
    }
    // Écrans moyens (iPhone standard)
    else if (width < 414) {
      return baseValue;
    }
    // Écrans grands (iPhone Pro Max, Android grand)
    else {
      return baseValue * (largeRatio ?? 1.2);
    }
  }

  // Padding adaptatif simple
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    final width = getScreenWidth(context);
    
    if (width < 375) {
      return const EdgeInsets.all(16);
    } else if (width < 414) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  // Taille de police adaptative
  static double getAdaptiveFontSize(BuildContext context, {
    required double baseSize,
    double? smallRatio = 0.9,
    double? largeRatio = 1.1,
  }) {
    return getResponsiveValue(
      context,
      baseValue: baseSize,
      smallRatio: smallRatio,
      largeRatio: largeRatio,
    );
  }

  // Espacement adaptatif
  static double getAdaptiveSpacing(BuildContext context, {
    required double baseSpacing,
    double? smallRatio = 0.8,
    double? largeRatio = 1.2,
  }) {
    return getResponsiveValue(
      context,
      baseValue: baseSpacing,
      smallRatio: smallRatio,
      largeRatio: largeRatio,
    );
  }
}

// Widget container adaptatif simple
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final AlignmentGeometry? alignment;

  const AdaptiveContainer({
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
      padding: padding ?? SimpleResponsive.getAdaptivePadding(context),
      alignment: alignment,
      child: child,
    );
  }
}

// Mixin pour faciliter l'utilisation dans les widgets
mixin ResponsiveMixin {
  double getResponsiveValue(BuildContext context, double baseValue) {
    return SimpleResponsive.getResponsiveValue(context, baseValue: baseValue);
  }

  double getAdaptiveFontSize(BuildContext context, double baseSize) {
    return SimpleResponsive.getAdaptiveFontSize(context, baseSize: baseSize);
  }

  double getAdaptiveSpacing(BuildContext context, double baseSpacing) {
    return SimpleResponsive.getAdaptiveSpacing(context, baseSpacing: baseSpacing);
  }

  EdgeInsets getAdaptivePadding(BuildContext context) {
    return SimpleResponsive.getAdaptivePadding(context);
  }
} 