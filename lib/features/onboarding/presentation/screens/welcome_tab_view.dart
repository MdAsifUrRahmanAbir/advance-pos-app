import 'package:flutter/material.dart';

import 'welcome_mobile_view.dart';

/// Same content as [WelcomeMobileView], centered in a fixed-width column
/// for wider (tablet/web) viewports.
class WelcomeTabView extends StatelessWidget {
  const WelcomeTabView({super.key});

  /// Within the project's 480–960 tablet range.
  static const double _maxContentWidth = 480;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _maxContentWidth),
        child: WelcomeMobileView(),
      ),
    );
  }
}