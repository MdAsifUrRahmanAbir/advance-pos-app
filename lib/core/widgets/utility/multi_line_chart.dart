import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class ChartSeries {
  final String label;
  final Color color;
  final List<double> values;

  const ChartSeries({required this.label, required this.color, required this.values});
}

/// Multi-series line chart with horizontal gridlines, y-axis value
/// labels, and x-axis category labels. Generic — used for any
/// time-series comparison (revenue vs expenses, etc.).
class MultiLineChart extends StatelessWidget {
  final List<ChartSeries> series;
  final List<String> yAxisLabels;
  final List<String> xAxisLabels;
  final double height;

  const MultiLineChart({
    super.key,
    required this.series,
    required this.yAxisLabels,
    required this.xAxisLabels,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSizes.xxl - AppSizes.xs,
            height: height - AppSizes.lg,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final label in yAxisLabels)
                  Text(label, style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textHint)),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _MultiLinePainter(series: series, gridLines: yAxisLabels.length),
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final label in xAxisLabels)
                      Text(label, style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textHint)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiLinePainter extends CustomPainter {
  final List<ChartSeries> series;
  final int gridLines;

  _MultiLinePainter({required this.series, required this.gridLines});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    for (var i = 0; i < gridLines; i++) {
      final y = size.height * i / (gridLines - 1);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final allValues = series.expand((s) => s.values).toList();
    if (allValues.isEmpty) return;
    final minVal = allValues.reduce((a, b) => a < b ? a : b);
    final maxVal = allValues.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

    for (final s in series) {
      if (s.values.length < 2) continue;
      final path = Path();
      for (var i = 0; i < s.values.length; i++) {
        final x = size.width * i / (s.values.length - 1);
        final y = size.height - ((s.values[i] - minVal) / range) * size.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MultiLinePainter oldDelegate) => oldDelegate.series != series;
}