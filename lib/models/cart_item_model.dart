
class CartItemModel {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;
  final String selectedSize;
  final int availableStock;

  const CartItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.selectedSize,
    required this.availableStock,
  });

  double get subtotal => price * quantity;

  CartItemModel copyWith({int? quantity}) => CartItemModel(
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        price: price,
        quantity: quantity ?? this.quantity,
        selectedSize: selectedSize,
        availableStock: availableStock,
      );

  Map<String, dynamic> toMap() => {
        'product_id': productId,
        'name': name,
        'image_url': imageUrl,
        'price': price,
        'quantity': quantity,
        'selected_size': selectedSize,
      };

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
        productId: map['product_id'] ?? '',
        name: map['name'] ?? '',
        imageUrl: map['image_url'] ?? '',
        price: (map['price'] ?? 0).toDouble(),
        quantity: map['quantity'] ?? 1,
        selectedSize: map['selected_size'] ?? '',
        availableStock: map['available_stock'] ?? 0,
      );
}
