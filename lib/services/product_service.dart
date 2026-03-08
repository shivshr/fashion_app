import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('products');

  // ─── READ ────────────────────────────────────────────────────────────────

  Stream<List<ProductModel>> streamFeaturedProducts() {
    return _col
        .where('is_active', isEqualTo: true)
        .where('is_featured', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((s) => s.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> streamProductsByCategory(String category) {
    return _col
        .where('is_active', isEqualTo: true)
        .where('category', isEqualTo: category)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<List<ProductModel>> streamAllProducts() {
    return _col
        .where('is_active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  // Admin - stream ALL products including inactive
  Stream<List<ProductModel>> streamAdminProducts() {
    return _col
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _col.doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromDoc(doc);
  }

  Future<List<ProductModel>> searchProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool inStockOnly = false,
  }) async {
    Query q = _col.where('is_active', isEqualTo: true);
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    if (inStockOnly) q = q.where('in_stock', isEqualTo: true);
    if (minPrice != null) q = q.where('price', isGreaterThanOrEqualTo: minPrice);
    if (maxPrice != null) q = q.where('price', isLessThanOrEqualTo: maxPrice);
    if (query != null && query.isNotEmpty) {
      q = q.where('tags', arrayContains: query.toLowerCase().trim());
    }
    final snap = await q.limit(50).get();
    return snap.docs.map((d) => ProductModel.fromDoc(d)).toList();
  }

  // ─── WRITE (ADMIN) ───────────────────────────────────────────────────────

  Future<String> addProduct(ProductModel product) async {
    final doc = _col.doc();
    final model = product.copyWith();
    final map = model.toMap();
    map['product_id'] = doc.id;
    await doc.set(map);
    return doc.id;
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    data['updated_at'] = FieldValue.serverTimestamp();
    await _col.doc(productId).update(data);
  }

  Future<void> deleteProduct(String productId) async {
    // Soft delete
    await _col.doc(productId).update({'is_active': false, 'updated_at': FieldValue.serverTimestamp()});
  }

  Future<void> toggleProductActive(String productId, bool isActive) async {
    await _col.doc(productId).update({'is_active': isActive, 'updated_at': FieldValue.serverTimestamp()});
  }

  // ─── STOCK ───────────────────────────────────────────────────────────────

  Future<void> decrementStock(String productId, int quantity) async {
    final ref = _col.doc(productId);
    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      final current = (snap['stock'] as int?) ?? 0;
      final newStock = (current - quantity).clamp(0, 999999);
      transaction.update(ref, {
        'stock': newStock,
        'in_stock': newStock > 0,
        'stock_status': ProductModel.deriveStockStatus(newStock),
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateStock(String productId, int stock) async {
    await _col.doc(productId).update({
      'stock': stock,
      'in_stock': stock > 0,
      'stock_status': ProductModel.deriveStockStatus(stock),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
