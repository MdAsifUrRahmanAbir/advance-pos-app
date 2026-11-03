import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/fly_to_target.dart';
import '../controllers/new_sale_controller.dart';
import '../states/new_sale_state.dart';
import '../widgets/cart_fly_thumbnail.dart';

/// View-layer wiring shared by [NewSaleMobileView] and [NewSaleTabView]
/// for "add to cart" feedback: the product thumbnail flies from the
/// tapped card to the cart badge, then the badge pulses. A product that
/// can't be added (stock limit reached) shows a snackbar instead.
mixin NewSaleViewActions<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Put on the cart bar's count badge — the flight's landing spot.
  final GlobalKey cartBadgeKey = GlobalKey();

  /// Bumped each time something lands in the cart; the badge pulses on
  /// every change.
  int cartPulse = 0;

  void pulseCart() {
    if (mounted) setState(() => cartPulse++);
  }

  /// [origin] is the tapped product card's context — where the flight
  /// starts.
  void addToCartWithFlight(ProductItem product, BuildContext origin) {
    // Read the start point before adding: the grid may rebuild after.
    final from = globalRectOf(origin);
    final added =
        ref.read(newSaleControllerProvider.notifier).addToCart(product);
    if (!added) {
      CustomSnackbar.show(
        context,
        AppStrings.productOutOfStockMessage(product.name),
        error: true,
      );
      return;
    }
    HapticFeedback.selectionClick();
    if (from == null) {
      pulseCart();
      return;
    }

    // Wait one frame: on the first add the cart bar only appears now.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final badgeContext = cartBadgeKey.currentContext;
      final to = badgeContext == null ? null : globalRectOf(badgeContext);
      if (to == null) {
        pulseCart();
        return;
      }
      flyToTarget(
        context,
        from: from,
        to: to,
        child: CartFlyThumbnail(product: product),
        onArrived: pulseCart,
      );
    });
  }
}
