import 'package:flutter/material.dart';

/// Shorthand for wrapping any widget in [Padding] — `myWidget.padding(...)`
/// instead of `Padding(padding: ..., child: myWidget)`. Purely a
/// readability helper; behaves identically to using [Padding] directly.
extension WidgetPaddingExtension on Widget {
  Widget padding(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  /// Convenience shortcuts for the common single-value / symmetric cases.
  Widget paddingAll(double value) => Padding(padding: EdgeInsets.all(value), child: this);

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Widget paddingOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
      child: this,
    );
  }
}