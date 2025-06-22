import 'package:bloc/bloc.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../models/pantry_item.dart';
import '../../models/recipe.dart';
import 'notification_state.dart';
import 'package:flutter/material.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService;

  NotificationCubit(this._notificationService)
    : super(const NotificationState());

  // Initialize and fetch notifications
  Future<void> initialize() async {
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      await _notificationService.initialize();

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
          status: NotificationStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Clear all notifications
  Future<void> clearAll() async {
    try {
      await _notificationService.clearAll();

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Create a notification about expiring pantry items
  Future<void> checkPantryItemsForNotifications(
    List<PantryItem> pantryItems,
  ) async {
    try {
      await _notificationService.checkPantryItemsForNotifications(pantryItems);

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Create a notification for a new recipe review
  Future<void> notifyAboutNewReview(
    Recipe recipe,
    String reviewerName,
    double rating,
  ) async {
    try {
      await _notificationService.notifyAboutNewReview(
        recipe,
        reviewerName,
        rating,
      );

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Create a notification for suggested recipes based on pantry items
  Future<void> suggestRecipeFromPantry(Recipe recipe) async {
    try {
      await _notificationService.suggestRecipeFromPantry(recipe);

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Create a notification for recipe saved
  Future<void> notifyRecipeSaved(String recipeName, {BuildContext? context, String? recipeId}) async {
    try {
      await _notificationService.notifyRecipeSaved(recipeName, recipeId: recipeId);

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
      
      // Show success notification popup if context is provided
      if (context != null) {
        _showSuccessNotification(context, 'Recipe saved to favorites!');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Create a notification for recipe removed
  Future<void> notifyRecipeRemoved(String recipeName, {BuildContext? context, String? recipeId}) async {
    try {
      await _notificationService.notifyRecipeRemoved(recipeName, recipeId: recipeId);

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
      
      // Show success notification popup if context is provided
      if (context != null) {
        _showSuccessNotification(context, 'Recipe removed from favorites!');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Create a notification for pantry item added
  Future<void> notifyPantryItemAdded(String itemName, {BuildContext? context, String? itemId}) async {
    try {
      await _notificationService.notifyPantryItemAdded(itemName, itemId: itemId);

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
      
      // Show success notification popup if context is provided
      if (context != null) {
        _showSuccessNotification(context, 'Item added to pantry!');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Create a notification for pantry item removed
  Future<void> notifyPantryItemRemoved(String itemName, {BuildContext? context, String? itemId}) async {
    try {
      await _notificationService.notifyPantryItemRemoved(itemName, itemId: itemId);

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
      
      // Show success notification popup if context is provided
      if (context != null) {
        _showSuccessNotification(context, 'Item removed from pantry!');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Create a notification for review submitted
  Future<void> notifyReviewSubmitted(String recipeName, {BuildContext? context, String? recipeId}) async {
    try {
      await _notificationService.notifyReviewSubmitted(recipeName, recipeId: recipeId);

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
      
      // Show success notification popup if context is provided
      if (context != null) {
        _showSuccessNotification(context, 'Review submitted successfully!');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Create a notification for rating submitted
  Future<void> notifyRatingSubmitted(String recipeName, double rating, {BuildContext? context, String? recipeId}) async {
    try {
      await _notificationService.notifyRatingSubmitted(recipeName, rating, recipeId: recipeId);

      emit(
        state.copyWith(
          notifications: _notificationService.notifications,
          hasNewNotifications: _notificationService.hasNewNotifications,
          unreadCount: _notificationService.unreadCount,
        ),
      );
      
      // Show success notification popup if context is provided
      if (context != null) {
        _showSuccessNotification(context, 'Rating submitted successfully!');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Helper method to show success notification
  void _showSuccessNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
