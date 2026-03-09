import 'package:fashion_app/models/cart_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  /// ADD ITEM
  void addItem(CartItemModel item) {
    final idx = state.indexWhere(
      (e) =>
          e.productId == item.productId &&
          e.selectedSize == item.selectedSize,
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

  /// REMOVE ITEM
  void removeItem(String productId, String size) {
    state = state
        .where((e) =>
            !(e.productId == productId && e.selectedSize == size))
        .toList();
  }

  /// UPDATE QUANTITY
  void updateQuantity(String productId, String size, int qty) {
    if (qty <= 0) {
      removeItem(productId, size);
      return;
    }

    state = state.map((e) {
      if (e.productId == productId && e.selectedSize == size) {
        return e.copyWith(
          quantity: qty.clamp(1, e.availableStock),
        );
      }
      return e;
    }).toList();
  }

  /// CLEAR CART
  void clearCart() {
    state = [];
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItemModel>>(
  (ref) => CartNotifier(),
);

/// ================================
/// DERIVED PROVIDERS (AUTO UPDATE)
/// ================================

/// SUBTOTAL
final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);

  return cart.fold(
    0,
    (sum, item) => sum + (item.price * item.quantity),
  );
});

/// SHIPPING
final cartShippingFeeProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);

  return subtotal >= 999 ? 0 : 99;
});

/// TOTAL
final cartTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final shipping = ref.watch(cartShippingFeeProvider);

  return subtotal + shipping;
});

/// ITEM COUNT
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);

  return cart.fold(
    0,
    (sum, item) => sum + item.quantity,
  );
});