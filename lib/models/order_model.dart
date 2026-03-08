import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_app/models/cart_item_model.dart';
import 'package:fashion_app/models/user_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String userPhone;
  final String userName;
  final List<CartItemModel> items;
  final AddressModel shippingAddress;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double totalPrice;
  final String paymentId;
  final String paymentStatus; // 'pending' | 'paid' | 'failed' | 'refunded'
  final String orderStatus; // 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled'
  final String paymentMethod;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.userPhone,
    required this.userName,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    this.discount = 0,
    this.shippingFee = 0,
    required this.totalPrice,
    this.paymentId = '',
    required this.paymentStatus,
    required this.orderStatus,
    this.paymentMethod = 'razorpay',
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel(
        orderId: map['order_id'] ?? '',
        userId: map['user_id'] ?? '',
        userPhone: map['user_phone'] ?? '',
        userName: map['user_name'] ?? '',
        items: (map['items'] as List<dynamic>? ?? [])
            .map((e) => CartItemModel.fromMap(e))
            .toList(),
        shippingAddress: AddressModel.fromMap(map['shipping_address'] ?? {}),
        subtotal: (map['subtotal'] ?? 0).toDouble(),
        discount: (map['discount'] ?? 0).toDouble(),
        shippingFee: (map['shipping_fee'] ?? 0).toDouble(),
        totalPrice: (map['total_price'] ?? 0).toDouble(),
        paymentId: map['payment_id'] ?? '',
        paymentStatus: map['payment_status'] ?? 'pending',
        orderStatus: map['order_status'] ?? 'pending',
        paymentMethod: map['payment_method'] ?? 'razorpay',
        notes: map['notes'],
        createdAt: (map['created_at'] as Timestamp?)?.toDate(),
        updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
      );

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    map['order_id'] = doc.id;
    return OrderModel.fromMap(map);
  }

  Map<String, dynamic> toMap() => {
        'order_id': orderId,
        'user_id': userId,
        'user_phone': userPhone,
        'user_name': userName,
        'items': items.map((e) => e.toMap()).toList(),
        'shipping_address': shippingAddress.toMap(),
        'subtotal': subtotal,
        'discount': discount,
        'shipping_fee': shippingFee,
        'total_price': totalPrice,
        'payment_id': paymentId,
        'payment_status': paymentStatus,
        'order_status': orderStatus,
        'payment_method': paymentMethod,
        'notes': notes,
        'created_at': createdAt ?? FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

  OrderModel copyWith({String? orderStatus, String? paymentStatus, String? paymentId}) => OrderModel(
        orderId: orderId,
        userId: userId,
        userPhone: userPhone,
        userName: userName,
        items: items,
        shippingAddress: shippingAddress,
        subtotal: subtotal,
        discount: discount,
        shippingFee: shippingFee,
        totalPrice: totalPrice,
        paymentId: paymentId ?? this.paymentId,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        orderStatus: orderStatus ?? this.orderStatus,
        paymentMethod: paymentMethod,
        notes: notes,
        createdAt: createdAt,
      );
}
