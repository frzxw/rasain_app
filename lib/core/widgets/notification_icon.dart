import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../services/notification_service.dart';
import '../../routes.dart';

class NotificationIcon extends StatelessWidget {
  final Color? iconColor;
  final double size;
  
  const NotificationIcon({
    super.key,
    this.iconColor,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: iconColor ?? Colors.orange,
                size: size,
              ),
              onPressed: () {
                context.push('/notifications');
              },
              tooltip: 'Notifikasi',
            ),
            
            if (notificationService.hasNewNotifications)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: notificationService.unreadCount > 0
                      ? Center(
                          child: Text(
                            notificationService.unreadCount > 9
                                ? '9+'
                                : notificationService.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }
}