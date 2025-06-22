// filepath: c:\Users\hp\Projects\rasain_app\lib\models\notification.dart
import 'package:flutter/material.dart';

enum NotificationType {
  recipeRecommendation, 
  expirationWarning, 
  lowStock, 
  newRecipe, 
  review, 
  achievement, 
  system,
  recipeSaved,
  recipeRemoved,
  pantryItemAdded,
  pantryItemRemoved,
  reviewSubmitted,
  ratingSubmitted
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final String? imageUrl;
  final String? actionUrl;
  final String? relatedItemId; // ID of related item (recipe ID, pantry item ID, etc.)
  final bool isRead;
  
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.imageUrl,
    this.actionUrl,
    this.relatedItemId,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.system,
      ),
      imageUrl: json['image_url'],
      actionUrl: json['action_url'],
      relatedItemId: json['related_item_id'],
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'image_url': imageUrl,
      'action_url': actionUrl,
      'related_item_id': relatedItemId,
      'is_read': isRead,
    };
  }

  // Create a copy of notification with modifications
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    String? imageUrl,
    String? actionUrl,
    String? relatedItemId,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      isRead: isRead ?? this.isRead,
    );
  }

  // Return appropriate icon for this notification type
  IconData get typeIcon {
    switch (type) {
      case NotificationType.recipeRecommendation:
        return Icons.recommend;
      case NotificationType.expirationWarning:
        return Icons.warning_amber_rounded;
      case NotificationType.lowStock:
        return Icons.inventory_2;
      case NotificationType.newRecipe:
        return Icons.restaurant_menu;
      case NotificationType.review:
        return Icons.rate_review;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.system:
        return Icons.notifications;
      case NotificationType.recipeSaved:
        return Icons.bookmark;
      case NotificationType.recipeRemoved:
        return Icons.bookmark_border;
      case NotificationType.pantryItemAdded:
        return Icons.add_shopping_cart;
      case NotificationType.pantryItemRemoved:
        return Icons.remove_shopping_cart;
      case NotificationType.reviewSubmitted:
        return Icons.rate_review;
      case NotificationType.ratingSubmitted:
        return Icons.star;
    }
  }

  // Return appropriate color for this notification type
  Color get typeColor {
    switch (type) {
      case NotificationType.recipeRecommendation:
        return Colors.green;
      case NotificationType.expirationWarning:
        return Colors.orange;
      case NotificationType.lowStock:
        return Colors.amber;
      case NotificationType.newRecipe:
        return Colors.purple;
      case NotificationType.review:
        return Colors.blue;
      case NotificationType.achievement:
        return Colors.yellow.shade800;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.recipeSaved:
        return Colors.green;
      case NotificationType.recipeRemoved:
        return Colors.red;
      case NotificationType.pantryItemAdded:
        return Colors.blue;
      case NotificationType.pantryItemRemoved:
        return Colors.orange;
      case NotificationType.reviewSubmitted:
        return Colors.purple;
      case NotificationType.ratingSubmitted:
        return Colors.amber;
    }
  }
}