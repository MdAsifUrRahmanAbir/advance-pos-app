import 'package:flutter/material.dart';

import '../../theme/app_color_scheme.dart';

/// Horizontal dashed line — receipt-style separator inside cards.
///
/// Themed: defaults to the current scheme's border color. Use [color] to
/// override and [thickness] for a heavier line.
class DashedDivider extends StatelessWidget {
  final Color? color;
  final double thickness;

  const DashedDivider({super.key, this.color, this.thickness = 1});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, thickness),
      painter: _DashPainter(
        color: color ?? context.appColors.border,
        thickness: thickness,
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  final double thickness;

  _DashPainter({required this.color, required this.thickness});

  /// FLAG: no dash tokens in AppSizes.
  static const double _dashWidth = 4;
  static const double _dashGap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += _dashWidth + _dashGap) {
      final end = (x + _dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) =>
      old.color != color || old.thickness != thickness;
}