import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground message: ${message.notification?.title}');
    });
  }

  Future<String?> getToken() => _fcm.getToken();

  Future<void> sendOrderConfirmation(String orderId, String userId) async {
    await _storeNotification(
      userId: userId,
      title: 'Order Placed! 🎉',
      body: 'Your order #${orderId.substring(0, 8)} has been placed successfully.',
      data: {'order_id': orderId, 'type': 'order_placed'},
    );
  }

  Future<void> sendOrderStatusUpdate(String orderId, String userId, String status) async {
    final statusMessages = {
      'processing': 'Your order is being processed 📦',
      'shipped': 'Your order has been shipped 🚚',
      'delivered': 'Your order has been delivered! 🎉',
      'cancelled': 'Your order has been cancelled.',
    };
    await _storeNotification(
      userId: userId,
      title: 'Order Update',
      body: statusMessages[status] ?? 'Your order status has been updated.',
      data: {'order_id': orderId, 'type': 'order_update', 'status': status},
    );
  }

  Future<void> _storeNotification({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': title,
      'body': body,
      'data': data,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
