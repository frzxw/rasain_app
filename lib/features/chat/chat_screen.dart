import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_bar.dart';
import '../../services/chat_service.dart';
import '../../models/chat_message.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_box.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load chat history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatService = Provider.of<ChatService>(context, listen: false);
      chatService.initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'AI Chef Assistant',
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showChatOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Consumer<ChatService>(
              builder: (context, chatService, _) {
                final messages = chatService.messages;
                
                if (chatService.isLoading && messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }
                
                if (messages.isEmpty) {
                  return _buildEmptyChatState();
                }
                
                // Scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatBubble(
                      message: message,
                      onRatePositive: () => chatService.rateMessage(message.id, true),
                      onRateNegative: () => chatService.rateMessage(message.id, false),
                    );
                  },
                );
              },
            ),
          ),
          
          // Loading indicator
          Consumer<ChatService>(
            builder: (context, chatService, _) {
              if (chatService.isLoading && chatService.messages.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Input box
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: ChatInputBox(
              onSendText: (text) {
                final chatService = Provider.of<ChatService>(context, listen: false);
                chatService.sendTextMessage(text);
              },
              onSendImage: (imageBytes, fileName) {
                final chatService = Provider.of<ChatService>(context, listen: false);
                chatService.sendImageMessage(imageBytes, fileName);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_outlined,
              size: AppSizes.iconXL,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              'Ask me anything about cooking!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              'I can help with cooking techniques, ingredient substitutions, or step-by-step recipe guidance.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginL),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSuggestionChip('How do I make fluffy pancakes?'),
                _buildSuggestionChip('What can I substitute for eggs?'),
                _buildSuggestionChip('Help me with knife techniques'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: InkWell(
        onTap: () {
          final chatService = Provider.of<ChatService>(context, listen: false);
          chatService.sendTextMessage(suggestion);
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(suggestion),
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Chat History'),
                  onTap: () {
                    Navigator.pop(context);
                    // Show chat history in a dialog or new screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Clear Chat'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmClearChat();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Tips'),
                  onTap: () {
                    Navigator.pop(context);
                    // Show help dialog
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmClearChat() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear your chat history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final chatService = Provider.of<ChatService>(context, listen: false);
              chatService.clearChatHistory();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
