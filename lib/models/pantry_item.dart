class PantryItem {
  final String id;
  final String name;
  final String? imageUrl;
  final String? quantity;
  final DateTime? expirationDate;
  final String? price;
  final String? unit;
  final String? category;

  PantryItem({
    required this.id,
    required this.name,
    this.imageUrl,
    this.quantity,
    this.expirationDate,
    this.price,
    this.unit,
    this.category,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      quantity: json['quantity'],
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'])
          : null,
      price: json['price'],
      unit: json['unit'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'quantity': quantity,
      'expiration_date': expirationDate?.toIso8601String(),
      'price': price,
      'unit': unit,
      'category': category,
    };
  }

  // Create a copy of pantry item with modifications
  PantryItem copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? quantity,
    DateTime? expirationDate,
    String? price,
    String? unit,
    String? category,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      expirationDate: expirationDate ?? this.expirationDate,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      category: category ?? this.category,
    );
  }
}
