import 'package:flutter/material.dart';
import '../../constants/app_sizes.dart';

/// Fixed-width horizontal spacer, meant to sit between two widgets in a
/// [Row]. Prefer the named constructors ([HGap.xs] ... [HGap.xxl]) so
/// spacing stays on the [AppSizes] scale — use the default constructor
/// only when a design value doesn't map to an existing token.
class HGap extends StatelessWidget {
  final double width;

  const HGap(this.width, {super.key});

  const HGap.xs({super.key}) : width = AppSizes.xs;
  const HGap.sm({super.key}) : width = AppSizes.sm;
  const HGap.md({super.key}) : width = AppSizes.md;
  const HGap.lg({super.key}) : width = AppSizes.lg;
  const HGap.xl({super.key}) : width = AppSizes.xl;
  const HGap.xxl({super.key}) : width = AppSizes.xxl;

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}

class VGap extends StatelessWidget {
  final double height;

  const VGap(this.height, {super.key});

  const VGap.xs({super.key}) : height = AppSizes.xs;
  const VGap.sm({super.key}) : height = AppSizes.sm;
  const VGap.md({super.key}) : height = AppSizes.md;
  const VGap.lg({super.key}) : height = AppSizes.lg;
  const VGap.xl({super.key}) : height = AppSizes.xl;
  const VGap.xxl({super.key}) : height = AppSizes.xxl;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}