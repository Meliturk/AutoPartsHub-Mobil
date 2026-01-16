class CartItem {
  CartItem({
    required this.partId,
    required this.name,
    required this.brand,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  final int partId;
  final String name;
  final String brand;
  final double price;
  final int quantity;
  final String? imageUrl;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      partId: partId,
      name: name,
      brand: brand,
      price: price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
    );
  }
}
