class PantryItem {
  final String id;
  final String? userId; // Add user_id field
  final String name;
  final String? imageUrl;
  final String? quantity;
  final DateTime? expirationDate;
  final String? price;
  final String? unit;
  final String? category;

  // New fields for enhanced tracking
  final String? storageLocation;
  final int? totalQuantity;
  final bool? lowStockAlert;
  final bool? expirationAlert;
  final DateTime? purchaseDate;
  final DateTime? lastUsedDate;

  PantryItem({
    required this.id,
    this.userId,
    required this.name,
    this.imageUrl,
    this.quantity,
    this.expirationDate,
    this.price,
    this.unit,
    this.category,
    this.storageLocation,
    this.totalQuantity,
    this.lowStockAlert,
    this.expirationAlert,
    this.purchaseDate,
    this.lastUsedDate,
  });
  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      imageUrl: json['image_url'],
      quantity: json['quantity'],
      expirationDate:
          json['expiration_date'] != null
              ? DateTime.parse(json['expiration_date'])
              : null,
      price: json['price'],
      unit: json['unit'],
      category: json['category'],
      storageLocation: json['storage_location'],
      totalQuantity: json['total_quantity'],
      lowStockAlert: json['low_stock_alert'],
      expirationAlert: json['expiration_alert'],
      purchaseDate:
          json['purchase_date'] != null
              ? DateTime.parse(json['purchase_date'])
              : null,
      lastUsedDate:
          json['last_used_date'] != null
              ? DateTime.parse(json['last_used_date'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'image_url': imageUrl,
      'quantity': quantity,
      'expiration_date': expirationDate?.toIso8601String(),
      'price': price,
      'unit': unit,
      'category': category,
      'storage_location': storageLocation,
      'total_quantity': totalQuantity,
      'low_stock_alert': lowStockAlert,
      'expiration_alert': expirationAlert,
      'purchase_date': purchaseDate?.toIso8601String(),
      'last_used_date': lastUsedDate?.toIso8601String(),
    };
  }

  // Create a copy of pantry item with modifications
  PantryItem copyWith({
    String? id,
    String? userId,
    String? name,
    String? imageUrl,
    String? quantity,
    DateTime? expirationDate,
    String? price,
    String? unit,
    String? category,
    String? storageLocation,
    int? totalQuantity,
    bool? lowStockAlert,
    bool? expirationAlert,
    DateTime? purchaseDate,
    DateTime? lastUsedDate,
  }) {
    return PantryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      expirationDate: expirationDate ?? this.expirationDate,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      storageLocation: storageLocation ?? this.storageLocation,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      expirationAlert: expirationAlert ?? this.expirationAlert,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
    );
  }

  // Helper method to check if the item is expiring soon (within 3 days)
  bool get isExpiringSoon {
    if (expirationDate == null) return false;

    final now = DateTime.now();
    final difference = expirationDate!.difference(now).inDays;
    return difference >= 0 && difference <= 3;
  }

  // Helper method to check if the item is low in stock
  bool get isLowStock {
    if (totalQuantity == null) return false;
    return totalQuantity! <= 1;
  }
}
