import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistNotifier extends StateNotifier<List<String>> {
  final String userId;
  WishlistNotifier(this.userId) : super([]) {
    _load();
  }

  final _db = FirebaseFirestore.instance;

  Future<void> _load() async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      state = List<String>.from(doc['wishlist'] ?? []);
    }
  }

  Future<void> toggle(String productId) async {
    final isIn = state.contains(productId);
    final newList = isIn
        ? state.where((id) => id != productId).toList()
        : [...state, productId];
    state = newList;
    await _db.collection('users').doc(userId).update({'wishlist': newList});
  }

  bool contains(String productId) => state.contains(productId);
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<String>>((ref) {
  final user = ref.watch(authStateProvider).value;
  return WishlistNotifier(user?.uid ?? '');
});
