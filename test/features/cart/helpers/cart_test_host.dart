import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:advance_pos_app/core/theme/app_theme.dart';
import 'package:advance_pos_app/features/cart/data/repositories/cart_repository.dart';
import 'package:advance_pos_app/features/cart/presentation/controllers/cart_controller.dart';
import 'package:advance_pos_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:advance_pos_app/features/cart/presentation/states/cart_state.dart';
import 'package:advance_pos_app/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:advance_pos_app/features/cart/presentation/widgets/quantity_stepper.dart';
import 'package:advance_pos_app/features/new_sale/presentation/controllers/new_sale_controller.dart';
import 'package:advance_pos_app/features/new_sale/presentation/states/new_sale_state.dart'
as new_sale;
import 'package:advance_pos_app/routes/route_names.dart';

import '../../invoices/helpers/invoice_test_harness.dart' show pumpFor;
import 'cart_fixtures.dart';
import 'seeded_new_sale_controller.dart';

const cartHostOpen = 'open-cart';
const cartPaymentStub = 'payment-stub';

/// The cart waits this long after a cart change before re-checking
/// discounts (CartController._debounceDelay is 400 ms).
const afterDebounce = Duration(milliseconds: 600);

/// Opens the real CartScreen from a host page (so Back has somewhere to
/// go), with a fake backend and a seeded New Sale cart.
Future<void> pumpCartApp(
    WidgetTester tester, {
      required CartRepository repository,
      List<new_sale.CartLineItem>? cart,
    }) async {
  final router = GoRouter(
    initialLocation: '/host',
    routes: [
      GoRoute(
        path: '/host',
        builder: (context, _) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.push(RouteNames.cart),
              child: const Text(cartHostOpen),
            ),
          ),
        ),
      ),
      GoRoute(path: RouteNames.cart, builder: (_, _) => const CartScreen()),
      GoRoute(
        path: RouteNames.payment,
        builder: (_, _) => const Scaffold(body: Text(cartPaymentStub)),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cartRepositoryProvider.overrideWithValue(repository),
        newSaleControllerProvider
            .overrideWith(() => SeededNewSaleController(cart ?? sampleCart())),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await pumpFor(tester);
  await tester.tap(find.text(cartHostOpen));
  await pumpFor(tester);
}

/// Current cart state, read straight from the provider.
CartState cartState(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(CartScreen)),
).read(cartControllerProvider);

// ── Finders ──

/// The cart's vertical list (text fields scroll sideways, so the first
/// downward Scrollable is the page list).
Finder get cartList => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
)
    .first;

Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 150, scrollable: cartList);
  await pumpFor(tester);
}

Finder cardOf(String name) =>
    find.ancestor(of: find.text(name), matching: find.byType(CartItemCard));

Finder stepButton(String name, IconData icon) =>
    find.descendant(of: cardOf(name), matching: find.byIcon(icon));

Finder qtyOf(String name, int qty) => find.descendant(
  of: find.descendant(
    of: cardOf(name),
    matching: find.byType(QuantityStepper),
  ),
  matching: find.text('$qty'),
);

/// Value text on the right of a summary row whose label is [label].
Finder summaryValue(String label) => find
    .descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
  matching: find.byType(Text),
)
    .last;

String textOf(WidgetTester tester, Finder finder) =>
    tester.widget<Text>(finder).data ?? '';

/// The TextField inside the labelled block (Discount, VAT, Remarks…).
Finder fieldUnder(String label) => find.descendant(
  of: find
      .ancestor(of: find.text(label).first, matching: find.byType(Column))
      .first,
  matching: find.byType(TextField),
);