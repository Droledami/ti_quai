import 'package:flutter/material.dart';

class BeachGradientDecoration extends BoxDecoration {
  const BeachGradientDecoration({
    super.gradient = const LinearGradient(
      begin: Alignment(0.00, -1.00),
      end: Alignment(0, 1),
      stops: [0.0, 0.08, 0.9, 1.0],
      colors: [
        Color(0xFF004E64),
        Color(0xFF00A5CF),
        Color(0xFFD4E997),
        Color(0xFFD4E997),
      ],
    ),
  });
}
