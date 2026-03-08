import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/models/order_model.dart';
import 'package:fashion_app/services/notification_service.dart';
import 'package:fashion_app/services/product_service.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _productService = ProductService();
  final _notifService = NotificationService();

  CollectionReference get _col => _db.collection('orders');

  Future<String> createOrder(OrderModel order) async {
    final doc = _col.doc();
    final map = order.toMap();
    map['order_id'] = doc.id;
    await doc.set(map);

    // Decrement stock for each item
    for (final item in order.items) {
      await _productService.decrementStock(item.productId, item.quantity);
    }

    // Send FCM notification
    await _notifService.sendOrderConfirmation(doc.id, order.userId);

    return doc.id;
  }

  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _col
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }

  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _col.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromDoc(doc);
  }

  // Admin
  Stream<List<OrderModel>> streamAllOrders({String? status}) {
    Query q = _col.orderBy('created_at', descending: true);
    if (status != null) q = q.where('order_status', isEqualTo: status);
    return q.snapshots().map((s) => s.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _col.doc(orderId).update({
      'order_status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });

    final order = await getOrder(orderId);
    if (order != null) {
      await _notifService.sendOrderStatusUpdate(orderId, order.userId, status);
    }
  }

  Future<void> updatePaymentStatus(String orderId, String paymentId, String status) async {
    await _col.doc(orderId).update({
      'payment_id': paymentId,
      'payment_status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    final snap = await _col.get();
    double total = 0;
    int paid = 0;
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['payment_status'] == 'paid') {
        total += (data['total_price'] ?? 0).toDouble();
        paid++;
      }
    }
    return {
      'total_orders': snap.docs.length,
      'paid_orders': paid,
      'total_revenue': total,
    };
  }
}
