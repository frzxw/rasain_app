import 'package:equatable/equatable.dart';
import '../../models/notification.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState extends Equatable {
  final List<AppNotification> notifications;
  final bool hasNewNotifications;
  final int unreadCount;
  final NotificationStatus status;
  final String? errorMessage;

  const NotificationState({
    this.notifications = const [],
    this.hasNewNotifications = false,
    this.unreadCount = 0,
    this.status = NotificationStatus.initial,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? hasNewNotifications,
    int? unreadCount,
    NotificationStatus? status,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      hasNewNotifications: hasNewNotifications ?? this.hasNewNotifications,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    notifications,
    hasNewNotifications,
    unreadCount,
    status,
    errorMessage,
  ];
}
