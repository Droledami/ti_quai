import 'package:flutter/material.dart';

ShapeDecoration buildAppBarDecoration(customColors) {
  return ShapeDecoration(
    gradient: LinearGradient(
      begin: const Alignment(0.00, -1.00),
      end: const Alignment(0, 1),
      stops: const [0.5, 8.0],
      colors: [
        customColors.primaryLight!,
        customColors.primary!,
      ],
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  );
}