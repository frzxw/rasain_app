import 'package:bloc/bloc.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../models/pantry_item.dart';
import '../../models/recipe.dart';
import 'notification_state.dart';

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
}
