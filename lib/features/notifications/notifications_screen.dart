import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_bar.dart';
import '../../cubits/notification/notification_cubit.dart';
import '../../cubits/notification/notification_state.dart';
import '../../models/notification.dart';
import '../../routes.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _filterUnreadOnly = false;
  @override
  void initState() {
    super.initState();
    // Initialize notifications data using NotificationCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<NotificationCubit>();
      cubit.initialize().then((_) {
        if (cubit.state.hasNewNotifications) {
          // Auto mark as read when opening the screen
          cubit.markAllAsRead();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Notifikasi',
        actions: [
          // Filter Toggle
          IconButton(
            icon: Icon(
              _filterUnreadOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
              color:
                  _filterUnreadOnly
                      ? AppColors.primary
                      : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _filterUnreadOnly = !_filterUnreadOnly;
              });
            },
            tooltip: 'Filter notifikasi yang belum dibaca',
          ),

          // Delete All Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear_all') {
                _confirmClearAll(context);
              } else if (value == 'mark_all_read') {
                context.read<NotificationCubit>().markAllAsRead();
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'mark_all_read',
                    child: ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: Text('Tandai semua dibaca'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'clear_all',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Hapus semua'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          final notifications =
              _filterUnreadOnly
                  ? state.notifications.where((n) => !n.isRead).toList()
                  : state.notifications;

          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<NotificationCubit>().initialize();
            },
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              itemCount: notifications.length,
              separatorBuilder:
                  (context, index) => const SizedBox(height: AppSizes.marginS),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(context, notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    AppNotification notification,
  ) {
    final notificationCubit = context.read<NotificationCubit>();
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.paddingL),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: AppSizes.iconM,
        ),
      ),
      onDismissed: (_) {
        notificationCubit.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notifikasi dihapus'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // This would need to restore the deleted notification
                // For demo purposes, we'll just refresh the screen
                notificationCubit.initialize();
              },
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          side: BorderSide(
            color:
                notification.isRead
                    ? AppColors.border
                    : AppColors.primary.withOpacity(0.5),
            width: notification.isRead ? 1 : 2,
          ),
        ),
        elevation: 0,
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: notification.typeColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification.typeIcon,
                    color: notification.typeColor,
                    size: AppSizes.iconM,
                  ),
                ),

                const SizedBox(width: AppSizes.marginM),

                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight:
                                    notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            timeago.format(
                              notification.timestamp,
                              locale: 'id',
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.marginXS),

                      // Message
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      // Image if available
                      if (notification.imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSizes.marginM),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusS,
                            ),
                            child: Image.network(
                              notification.imageUrl!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (ctx, error, _) => Container(
                                    height: 80,
                                    width: double.infinity,
                                    color: AppColors.surface,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                            ),
                          ),
                        ),

                      const SizedBox(height: AppSizes.marginM),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // View Button
                          OutlinedButton(
                            onPressed:
                                () => _handleNotificationTap(notification),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingM,
                                vertical: AppSizes.paddingXS,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusL,
                                ),
                              ),
                              side: BorderSide(
                                color:
                                    notification.isRead
                                        ? AppColors.border
                                        : notification.typeColor,
                              ),
                            ),
                            child: Text(
                              _getActionButtonText(notification.type),
                              style: TextStyle(
                                color:
                                    notification.isRead
                                        ? AppColors.textPrimary
                                        : notification.typeColor,
                              ),
                            ),
                          ),

                          const SizedBox(width: AppSizes.marginS),

                          // Mark as Read/Unread toggle
                          IconButton(
                            icon: Icon(
                              notification.isRead
                                  ? Icons.visibility_off_outlined
                                  : Icons.check_circle_outline,
                              size: AppSizes.iconS,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              if (notification.isRead) {
                                // This would mark as unread in a real app
                                // For demo purposes, we'll just show a message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Fitur tandai belum dibaca akan segera hadir',
                                    ),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              } else {
                                notificationCubit.markAsRead(notification.id);
                              }
                            },
                            tooltip:
                                notification.isRead
                                    ? 'Tandai belum dibaca'
                                    : 'Tandai sudah dibaca',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getActionButtonText(NotificationType type) {
    switch (type) {
      case NotificationType.recipeRecommendation:
        return 'Lihat Resep';
      case NotificationType.expirationWarning:
        return 'Lihat Bahan';
      case NotificationType.lowStock:
        return 'Lihat Stok';
      case NotificationType.newRecipe:
        return 'Eksplor Resep';
      case NotificationType.review:
        return 'Lihat Ulasan';
      case NotificationType.achievement:
        return 'Lihat Detail';
      case NotificationType.system:
        return 'Detail';
      case NotificationType.recipeSaved:
      case NotificationType.recipeRemoved:
        return 'Lihat Favorit';
      case NotificationType.pantryItemAdded:
      case NotificationType.pantryItemRemoved:
        return 'Lihat Dapur';
      case NotificationType.reviewSubmitted:
      case NotificationType.ratingSubmitted:
        return 'Lihat Ulasan';
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark notification as read
    context.read<NotificationCubit>().markAsRead(notification.id);

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.recipeRecommendation:
      case NotificationType.newRecipe:
        if (notification.relatedItemId != null) {
          context.go('/recipe/${notification.relatedItemId}');
        }
        break;

      case NotificationType.expirationWarning:
      case NotificationType.lowStock:
      case NotificationType.pantryItemAdded:
      case NotificationType.pantryItemRemoved:
        // Navigate to pantry view
        context.go('/pantry');
        break;

      case NotificationType.review:
      case NotificationType.reviewSubmitted:
      case NotificationType.ratingSubmitted:
        // Navigate to recipe reviews
        if (notification.relatedItemId != null) {
          context.go(
            '/recipe/${notification.relatedItemId}',
            extra: {'scrollToReview': true},
          );
        }
        break;

      case NotificationType.recipeSaved:
      case NotificationType.recipeRemoved:
        // Navigate to profile to see saved recipes
        context.go('/profile');
        break;

      case NotificationType.achievement:
      case NotificationType.system:
        // Just mark as read, no specific action
        break;
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Semua Notifikasi'),
            content: const Text(
              'Anda yakin ingin menghapus semua notifikasi? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<NotificationCubit>().clearAll();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Hapus Semua'),
              ),
            ],
          ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: AppSizes.iconXL,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              _filterUnreadOnly
                  ? 'Tidak ada notifikasi yang belum dibaca'
                  : 'Tidak ada notifikasi',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginS),
            Text(
              _filterUnreadOnly
                  ? 'Semua notifikasi telah ditandai sebagai dibaca'
                  : 'Anda akan menerima notifikasi tentang bahan yang hampir kadaluarsa, stok yang menipis, atau rekomendasi resep',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginL),
            if (_filterUnreadOnly)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _filterUnreadOnly = false;
                  });
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Lihat Semua Notifikasi'),
              ),
          ],
        ),
      ),
    );
  }
}
