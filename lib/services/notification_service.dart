// filepath: c:\Users\hp\Projects\rasain_app\lib\services\notification_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import 'auth_service.dart';

class NotificationService extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  bool _isLoading = false;
  bool _hasNewNotifications = false;
  Timer? _checkExpirationTimer;
  String? _currentUserId;
  
  // Getters
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasNewNotifications => _hasNewNotifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  // Initialize notification service
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _loadNotifications();
      _startExpirationCheck();
      
      // Add some sample notifications for demo purposes only if user is logged in
      if (_notifications.isEmpty && _currentUserId != null) {
        _addSampleNotifications();
      }
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Set current user ID and load their notifications
  Future<void> setCurrentUser(String? userId) async {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      
      if (userId == null) {
        // User logged out, clear notifications
        await clearAll();
      } else {
        // User logged in, load their notifications
        await _loadNotifications();
      }
    }
  }
  
  // Load notifications from storage
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _currentUserId != null ? 'notifications_$_currentUserId' : 'notifications_guest';
      final notificationsJson = prefs.getStringList(key) ?? [];
      
      _notifications.clear();
      for (final json in notificationsJson) {
        final notification = AppNotification.fromJson(jsonDecode(json));
        _notifications.add(notification);
      }
      
      // Sort by timestamp (newest first)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Check for unread notifications
      _hasNewNotifications = _notifications.any((notification) => !notification.isRead);
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }
  
  // Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _currentUserId != null ? 'notifications_$_currentUserId' : 'notifications_guest';
      final notificationsJson = _notifications
          .map((notification) => jsonEncode(notification.toJson()))
          .toList();
      
      await prefs.setStringList(key, notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }
  
  // Add a new notification
  Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? imageUrl,
    String? actionUrl,
    String? relatedItemId,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      relatedItemId: relatedItemId,
    );
    
    _notifications.insert(0, notification); // Add to beginning of list
    _hasNewNotifications = true;
    
    await _saveNotifications();
    notifyListeners();
  }
  
  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications[index] = notification.copyWith(isRead: true);
      
      // Check if there are any unread notifications left
      _hasNewNotifications = _notifications.any((notification) => !notification.isRead);
      
      await _saveNotifications();
      notifyListeners();
    }
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final updated = _notifications.map((notification) => 
      notification.isRead ? notification : notification.copyWith(isRead: true)
    ).toList();
    
    _notifications.clear();
    _notifications.addAll(updated);
    _hasNewNotifications = false;
    
    await _saveNotifications();
    notifyListeners();
  }
  
  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((notification) => notification.id == notificationId);
    
    // Check if there are any unread notifications left
    _hasNewNotifications = _notifications.any((notification) => !notification.isRead);
    
    await _saveNotifications();
    notifyListeners();
  }
  
  // Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    _hasNewNotifications = false;
    
    await _saveNotifications();
    notifyListeners();
  }
  
  // Start periodic check for expiring items
  void _startExpirationCheck() {
    // Check every 6 hours for expiring items
    _checkExpirationTimer = Timer.periodic(const Duration(hours: 6), (_) {
      _checkExpiringItems();
    });
    
    // Run a check immediately
    _checkExpiringItems();
  }
  
  // Check for expiring items in pantry
  Future<void> _checkExpiringItems() async {
    // This would actually call a real service or check a database
    // For demo purposes, this is just a placeholder
  }
  
  // Helper: Create sample notifications for demo purposes
  void _addSampleNotifications() {
    // Expiration warning notification
    _notifications.add(AppNotification(
      id: '1',
      title: 'Bahan Hampir Kadaluarsa',
      message: 'Tomat akan kadaluarsa dalam 2 hari. Jangan lupa untuk segera menggunakannya!',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.expirationWarning,
      relatedItemId: 'pantry-item-123',
    ));
    
    // Low stock notification
    _notifications.add(AppNotification(
      id: '2',
      title: 'Stok Hampir Habis',
      message: 'Bawang putih hampir habis. Tambahkan ke daftar belanja Anda.',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      type: NotificationType.lowStock,
      relatedItemId: 'pantry-item-456',
    ));
    
    // Recipe recommendation
    _notifications.add(AppNotification(
      id: '3',
      title: 'Resep yang Direkomendasikan',
      message: 'Coba Nasi Goreng Kampung ini dengan bahan yang Anda miliki di dapur!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.recipeRecommendation,
      relatedItemId: 'recipe-123',
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?q=80&w=1000&auto=format&fit=crop',
    ));
    

    
    // Achievement notification
    _notifications.add(AppNotification(
      id: '5',
      title: 'Pencapaian Baru!',
      message: 'Selamat! Anda telah mencoba 10 resep. Lanjutkan!',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      type: NotificationType.achievement,
    ));
  }
  
  // Create notifications based on pantry items
  Future<void> checkPantryItemsForNotifications(List<PantryItem> pantryItems) async {
    final expiringItems = pantryItems.where((item) => 
      item.expirationAlert == true && item.isExpiringSoon
    ).toList();
    
    final lowStockItems = pantryItems.where((item) => 
      item.lowStockAlert == true && item.isLowStock
    ).toList();
    
    // Create notifications for expiring items
    for (final item in expiringItems) {
      final existingNotification = _notifications.any((notification) => 
        notification.type == NotificationType.expirationWarning && 
        notification.relatedItemId == item.id
      );
      
      if (!existingNotification) {
        await addNotification(
          title: 'Bahan Hampir Kadaluarsa',
          message: '${item.name} akan kadaluarsa dalam ${_getDaysUntilExpiration(item)} hari. '
                 'Jangan lupa untuk segera menggunakannya!',
          type: NotificationType.expirationWarning,
          relatedItemId: item.id,
        );
      }
    }
    
    // Create notifications for low stock items
    for (final item in lowStockItems) {
      final existingNotification = _notifications.any((notification) => 
        notification.type == NotificationType.lowStock && 
        notification.relatedItemId == item.id
      );
      
      if (!existingNotification) {
        await addNotification(
          title: 'Stok Hampir Habis',
          message: '${item.name} hampir habis. Tambahkan ke daftar belanja Anda.',
          type: NotificationType.lowStock,
          relatedItemId: item.id,
        );
      }
    }
  }
  
  // Create notifications for recipe reviews
  Future<void> notifyAboutNewReview(Recipe recipe, String reviewerName, double rating) async {
    await addNotification(
      title: 'Ulasan Baru',
      message: '$reviewerName memberikan resep ${recipe.name} bintang $rating! Klik untuk melihat ulasannya.',
      type: NotificationType.review,
      relatedItemId: recipe.id,
      imageUrl: recipe.imageUrl,
    );
  }
  
  // Create notification for recipe suggestions
  Future<void> suggestRecipeFromPantry(Recipe recipe) async {
    await addNotification(
      title: 'Resep yang Direkomendasikan',
      message: 'Coba ${recipe.name} ini dengan bahan yang Anda miliki di dapur!',
      type: NotificationType.recipeRecommendation,
      relatedItemId: recipe.id,
      imageUrl: recipe.imageUrl,
    );
  }
  
  // Helper method to get days until expiration
  int _getDaysUntilExpiration(PantryItem item) {
    if (item.expirationDate == null) return 0;
    
    final now = DateTime.now();
    return item.expirationDate!.difference(now).inDays;
  }
  
  // Create notification for recipe saved
  Future<void> notifyRecipeSaved(String recipeName, {String? recipeId}) async {
    await addNotification(
      title: 'Resep Disimpan',
      message: '$recipeName telah ditambahkan ke daftar favorit Anda!',
      type: NotificationType.recipeSaved,
      relatedItemId: recipeId,
    );
  }

  // Create notification for recipe removed from favorites
  Future<void> notifyRecipeRemoved(String recipeName, {String? recipeId}) async {
    await addNotification(
      title: 'Resep Dihapus',
      message: '$recipeName telah dihapus dari daftar favorit Anda.',
      type: NotificationType.recipeRemoved,
      relatedItemId: recipeId,
    );
  }

  // Create notification for pantry item added
  Future<void> notifyPantryItemAdded(String itemName, {String? itemId}) async {
    await addNotification(
      title: 'Bahan Ditambahkan',
      message: '$itemName telah ditambahkan ke dapur Anda.',
      type: NotificationType.pantryItemAdded,
      relatedItemId: itemId,
    );
  }

  // Create notification for pantry item removed
  Future<void> notifyPantryItemRemoved(String itemName, {String? itemId}) async {
    await addNotification(
      title: 'Bahan Dihapus',
      message: '$itemName telah dihapus dari dapur Anda.',
      type: NotificationType.pantryItemRemoved,
      relatedItemId: itemId,
    );
  }

  // Create notification for review submitted
  Future<void> notifyReviewSubmitted(String recipeName, {String? recipeId}) async {
    await addNotification(
      title: 'Ulasan Dikirim',
      message: 'Terima kasih! Ulasan Anda untuk $recipeName telah berhasil dikirim.',
      type: NotificationType.reviewSubmitted,
      relatedItemId: recipeId,
    );
  }

  // Create notification for rating submitted
  Future<void> notifyRatingSubmitted(String recipeName, double rating, {String? recipeId}) async {
    await addNotification(
      title: 'Rating Dikirim',
      message: 'Anda memberikan $rating bintang untuk $recipeName. Terima kasih!',
      type: NotificationType.ratingSubmitted,
      relatedItemId: recipeId,
    );
  }
  
  @override
  void dispose() {
    _checkExpirationTimer?.cancel();
    super.dispose();
  }
}