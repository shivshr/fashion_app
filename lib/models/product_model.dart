import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String name;
  final String description;
  final double price;
  final double? comparePrice;
  final String category;
  final String subCategory;
  final List<String> tags;
  final List<String> imageUrls;
  final List<String> sizes;
  final List<String> colors;
  final int stock;
  final bool inStock;
  final String stockStatus; // 'in_stock' | 'low_stock' | 'out_of_stock'
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    this.comparePrice,
    required this.category,
    this.subCategory = '',
    this.tags = const [],
    required this.imageUrls,
    this.sizes = const [],
    this.colors = const [],
    required this.stock,
    required this.inStock,
    required this.stockStatus,
    this.rating = 0,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  double get discountPercent {
    if (comparePrice == null || comparePrice! <= price) return 0;
    return ((comparePrice! - price) / comparePrice! * 100).roundToDouble();
  }

  static String deriveStockStatus(int qty) {
    if (qty == 0) return 'out_of_stock';
    if (qty <= 5) return 'low_stock';
    return 'in_stock';
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['product_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      comparePrice: map['compare_price']?.toDouble(),
      category: map['category'] ?? '',
      subCategory: map['sub_category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      sizes: List<String>.from(map['sizes'] ?? []),
      colors: List<String>.from(map['colors'] ?? []),
      stock: map['stock'] ?? 0,
      inStock: map['in_stock'] ?? false,
      stockStatus: map['stock_status'] ?? 'out_of_stock',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['review_count'] ?? 0,
      isFeatured: map['is_featured'] ?? false,
      isActive: map['is_active'] ?? true,
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    map['product_id'] = doc.id;
    return ProductModel.fromMap(map);
  }

  Map<String, dynamic> toMap() => {
        'product_id': productId,
        'name': name,
        'description': description,
        'price': price,
        'compare_price': comparePrice,
        'category': category,
        'sub_category': subCategory,
        'tags': tags,
        'image_urls': imageUrls,
        'sizes': sizes,
        'colors': colors,
        'stock': stock,
        'in_stock': inStock,
        'stock_status': stockStatus,
        'rating': rating,
        'review_count': reviewCount,
        'is_featured': isFeatured,
        'is_active': isActive,
        'created_at': createdAt ?? FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

  ProductModel copyWith({
    String? name,
    String? description,
    double? price,
    double? comparePrice,
    String? category,
    String? subCategory,
    List<String>? tags,
    List<String>? imageUrls,
    List<String>? sizes,
    List<String>? colors,
    int? stock,
    bool? inStock,
    String? stockStatus,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isActive,
  }) =>
      ProductModel(
        productId: productId,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        comparePrice: comparePrice ?? this.comparePrice,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        tags: tags ?? this.tags,
        imageUrls: imageUrls ?? this.imageUrls,
        sizes: sizes ?? this.sizes,
        colors: colors ?? this.colors,
        stock: stock ?? this.stock,
        inStock: inStock ?? this.inStock,
        stockStatus: stockStatus ?? this.stockStatus,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        isFeatured: isFeatured ?? this.isFeatured,
        isActive: isActive ?? this.isActive,
      );
}
