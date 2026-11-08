import 'package:advance_pos_app/features/new_sale/presentation/controllers/new_sale_controller.dart';
import 'package:advance_pos_app/features/new_sale/presentation/states/new_sale_state.dart';

/// The real NewSaleController (so +/−, delete, clear and the stock cap
/// run unchanged), started with [seed] in the cart and with the product
/// API switched off.
class SeededNewSaleController extends NewSaleController {
  SeededNewSaleController(this.seed);

  final List<CartLineItem> seed;

  @override
  NewSaleState build() => super.build().copyWith(cartItems: seed);

  @override
  Future<bool> getProducts({bool reset = false}) async => true;
}