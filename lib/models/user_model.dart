import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String street;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;

  const AddressModel({
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) => AddressModel(
        street: map['street'] ?? '',
        city: map['city'] ?? '',
        state: map['state'] ?? '',
        pincode: map['pincode'] ?? '',
        landmark: map['landmark'],
      );

  Map<String, dynamic> toMap() => {
        'street': street,
        'city': city,
        'state': state,
        'pincode': pincode,
        'landmark': landmark,
      };

  @override
  String toString() => '$street, $city, $state - $pincode';
}

class UserModel {
  final String uid;
  final String phone;
  final String? name;
  final String? email;
  final String? photoUrl;
  final AddressModel? address;
  final List<String> wishlist;
  final String? fcmToken;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.phone,
    this.name,
    this.email,
    this.photoUrl,
    this.address,
    this.wishlist = const [],
    this.fcmToken,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] ?? '',
        phone: map['phone'] ?? '',
        name: map['name'],
        email: map['email'],
        photoUrl: map['photo_url'],
        address: map['address'] != null ? AddressModel.fromMap(map['address']) : null,
        wishlist: List<String>.from(map['wishlist'] ?? []),
        fcmToken: map['fcm_token'],
        createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'phone': phone,
        'name': name,
        'email': email,
        'photo_url': photoUrl,
        'address': address?.toMap(),
        'wishlist': wishlist,
        'fcm_token': fcmToken,
        'created_at': createdAt ?? FieldValue.serverTimestamp(),
      };

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    AddressModel? address,
    List<String>? wishlist,
    String? fcmToken,
  }) =>
      UserModel(
        uid: uid,
        phone: phone,
        name: name ?? this.name,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        address: address ?? this.address,
        wishlist: wishlist ?? this.wishlist,
        fcmToken: fcmToken ?? this.fcmToken,
        createdAt: createdAt,
      );
}
