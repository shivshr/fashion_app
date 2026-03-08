import 'package:fashion_app/models/cart_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addItem(CartItemModel item) {
    final idx = state.indexWhere(
      (e) => e.productId == item.productId && e.selectedSize == item.selectedSize,
    );
    if (idx >= 0) {
      final existing = state[idx];
      final newQty = existing.quantity + item.quantity;
      if (newQty <= existing.availableStock) {
        state = [
          ...state.sublist(0, idx),
          existing.copyWith(quantity: newQty),
          ...state.sublist(idx + 1),
        ];
      }
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String productId, String size) {
    state = state.where((e) => !(e.productId == productId && e.selectedSize == size)).toList();
  }

  void updateQuantity(String productId, String size, int qty) {
    if (qty <= 0) {
      removeItem(productId, size);
      return;
    }
    state = state.map((e) {
      if (e.productId == productId && e.selectedSize == size) {
        return e.copyWith(quantity: qty.clamp(1, e.availableStock));
      }
      return e;
    }).toList();
  }

  void clearCart() => state = [];

  double get subtotal => state.fold(0, (sum, e) => sum + e.subtotal);

  double get shippingFee => subtotal >= 999 ? 0 : 99;

  double get total => subtotal + shippingFee;

  int get itemCount => state.fold(0, (sum, e) => sum + e.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>(
  (ref) => CartNotifier(),
);

final cartSubtotalProvider = Provider<double>((ref) => ref.watch(cartProvider.notifier).subtotal);
final cartTotalProvider = Provider<double>((ref) => ref.watch(cartProvider.notifier).total);
final cartItemCountProvider = Provider<int>((ref) => ref.watch(cartProvider.notifier).itemCount);
final cartShippingFeeProvider = Provider<double>((ref) => ref.watch(cartProvider.notifier).shippingFee);
