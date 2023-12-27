import 'package:flutter/material.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.secondaryLight,
    required this.tertiary,
    required this.tertiaryDark,
    required this.special,
    required this.cardQuarterTransparency,
    required this.cardHalfTransparency,
  });

  final Color? primary;
  final Color? primaryDark;
  final Color? primaryLight;
  final Color? secondary;
  final Color? secondaryLight;
  final Color? tertiary;
  final Color? tertiaryDark;
  final Color? special;
  final Color? cardQuarterTransparency;
  final Color? cardHalfTransparency;

  @override
  ThemeExtension<CustomColors> copyWith(
      {Color? primary,
      Color? primaryDark,
      Color? primaryLight,
      Color? secondary,
      Color? secondaryLight,
      Color? tertiary,
      Color? tertiaryDark,
      Color? special,
      Color? cardQuarterTransparency,
      Color? cardHalfTransparency}) {
    return CustomColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      secondary: secondary ?? this.secondary,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      tertiary: tertiary ?? this.tertiary,
      tertiaryDark: tertiaryDark ?? this.tertiaryDark,
      special: special ?? this.special,
      cardQuarterTransparency:
          cardQuarterTransparency ?? this.cardQuarterTransparency,
      cardHalfTransparency: cardHalfTransparency ?? this.cardHalfTransparency,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(
      covariant ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      primary: Color.lerp(primary, other.primary, t),
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t),
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t),
      secondary: Color.lerp(secondary, other.secondary, t),
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t),
      tertiary: Color.lerp(tertiary, other.tertiary, t),
      tertiaryDark: Color.lerp(tertiaryDark, other.tertiaryDark, t),
      special: Color.lerp(special, other.special, t),
      cardQuarterTransparency:
          Color.lerp(cardQuarterTransparency, other.cardQuarterTransparency, t),
      cardHalfTransparency:
          Color.lerp(cardHalfTransparency, other.cardHalfTransparency, t),
    );
  }
}
