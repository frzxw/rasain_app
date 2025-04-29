import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRatePositive;
  final VoidCallback? onRateNegative;
  
  const ChatBubble({
    Key? key,
    required this.message,
    this.onRatePositive,
    this.onRateNegative,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Profile Picture (only for AI messages)
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: AppSizes.marginS),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.smart_toy_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          
          // Message Container
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusM).copyWith(
                  bottomLeft: isUser ? null : const Radius.circular(0),
                  bottomRight: isUser ? const Radius.circular(0) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message Content
                  if (message.type == MessageType.text)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? AppColors.onPrimary : AppColors.textPrimary,
                      ),
                    ),
                  
                  if (message.type == MessageType.image && message.imageUrl != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          child: Image.network(
                            message.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              height: 150,
                              color: AppColors.surface,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (message.content.isNotEmpty && message.content != 'Image')
                          Padding(
                            padding: const EdgeInsets.only(top: AppSizes.paddingS),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color: isUser ? AppColors.onPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  
                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.paddingS),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: isUser ? AppColors.onPrimary.withOpacity(0.7) : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // User Profile Picture (only for user messages)
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: AppSizes.marginS),
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person_outline,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
      
      // Rating Actions (only for AI messages)
    ).followed(
      !isUser ? _buildRatingBar(context) : const SizedBox.shrink(),
    );
  }
  
  Widget _buildRatingBar(BuildContext context) {
    if (onRatePositive == null || onRateNegative == null) {
      return const SizedBox.shrink();
    }
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 36 + AppSizes.marginS,
          bottom: AppSizes.paddingM,
        ),
        child: Row(
          children: [
            InkWell(
              onTap: message.isRatedPositive == true ? null : onRatePositive,
              borderRadius: BorderRadius.circular(AppSizes.radiusXS),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingXS),
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 14,
                      color: message.isRatedPositive == true
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Helpful',
                      style: TextStyle(
                        fontSize: 12,
                        color: message.isRatedPositive == true
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSizes.marginM),
            InkWell(
              onTap: message.isRatedNegative == true ? null : onRateNegative,
              borderRadius: BorderRadius.circular(AppSizes.radiusXS),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingXS),
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_down_outlined,
                      size: 14,
                      color: message.isRatedNegative == true
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Not Helpful',
                      style: TextStyle(
                        fontSize: 12,
                        color: message.isRatedNegative == true
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      // Today, show time only
      return DateFormat.jm().format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday, ${DateFormat.jm().format(dateTime)}';
    } else {
      // Other days
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }
}

extension WidgetExtension on Widget {
  Widget followed(Widget widget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [this, widget],
    );
  }
}
