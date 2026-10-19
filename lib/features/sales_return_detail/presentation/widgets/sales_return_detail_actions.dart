import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/bottom_action_bar.dart';
import '../../../../core/widgets/common/primary_button.dart';

/// Sticky bottom bar with the Share action. [onShare] receives the button's
/// on-screen rectangle (needed as the share-sheet anchor on iPad).
class SalesReturnDetailActions extends StatelessWidget {
  final ValueChanged<Rect?> onShare;

  const SalesReturnDetailActions({super.key, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return BottomActionBar(
      child: PrimaryButton(
        label: AppStrings.invoiceShareAction,
        icon: Icons.share_outlined,
        onPressed: () {
          final box = context.findRenderObject() as RenderBox?;
          onShare(
            box == null || !box.hasSize
                ? null
                : box.localToGlobal(Offset.zero) & box.size,
          );
        },
      ),
    );
  }
}