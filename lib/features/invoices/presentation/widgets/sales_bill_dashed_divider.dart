import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Dotted separator line used between receipt sections.
class SalesBillDashedDivider extends StatelessWidget {
  const SalesBillDashedDivider({super.key});

  // Dash geometry — no AppSizes tokens for hairlines, flagged.
  static const double _thickness = 1;
  static const double _dash = 2;
  static const double _gap = 2;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: SizedBox(
        height: _thickness,
        width: double.infinity,
        child: CustomPaint(painter: _DashPainter()),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = SalesBillDashedDivider._thickness;
    final y = size.height / 2;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x + SalesBillDashedDivider._dash, y),
        paint,
      );
      x += SalesBillDashedDivider._dash + SalesBillDashedDivider._gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) => false;
}