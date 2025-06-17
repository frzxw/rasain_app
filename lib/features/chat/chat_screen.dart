import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_bar.dart';
import '../../cubits/chat/chat_cubit.dart';
import '../../cubits/chat/chat_state.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_box.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // Load chat history using ChatCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().initialize();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Virtual Cooking Assistant',
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
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                final messages = state.messages;

                if (state.status == ChatStatus.loading && messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
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
                      onRatePositive:
                          () => context.read<ChatCubit>().rateMessagePositive(
                            message.id,
                          ),
                      onRateNegative:
                          () => context.read<ChatCubit>().rateMessageNegative(
                            message.id,
                          ),
                    );
                  },
                );
              },
            ),
          ),
          // Loading indicator
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if ((state.status == ChatStatus.loading ||
                      state.status == ChatStatus.sending) &&
                  state.messages.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingS,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ), // Input box
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: ChatInputBox(
              onSendText: (text) {
                context.read<ChatCubit>().sendTextMessage(text);
              },
              onSendImage: (imageBytes, fileName) {
                // Convert List<int> to Uint8List before passing to Cubit
                final Uint8List uint8list = Uint8List.fromList(imageBytes);
                context.read<ChatCubit>().sendImageMessage(uint8list);
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
              'Tanya saya tentang masakan Indonesia!', // Changed to Indonesian
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              'Saya dapat membantu dengan teknik memasak, pengganti bahan, atau panduan resep langkah demi langkah.', // Changed to Indonesian
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginL),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Updated with Indonesian cuisine suggestions
                _buildSuggestionChip(
                  'Bagaimana cara membuat rendang yang empuk?',
                ),
                _buildSuggestionChip('Apa bahan pengganti santan?'),
                _buildSuggestionChip(
                  'Bagaimana cara membuat sambal yang enak?',
                ),
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
          context.read<ChatCubit>().sendTextMessage(suggestion);
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
                  title: const Text('Riwayat Chat'), // Changed to Indonesian
                  onTap: () {
                    Navigator.pop(context);
                    // Show chat history in a dialog or new screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Hapus Chat'), // Changed to Indonesian
                  onTap: () {
                    Navigator.pop(context);
                    _confirmClearChat();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Bantuan & Tips'), // Changed to Indonesian
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
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Chat'), // Changed to Indonesian
            content: const Text(
              'Apakah Anda yakin ingin menghapus riwayat chat? Tindakan ini tidak dapat dibatalkan.',
            ), // Changed to Indonesian
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'), // Changed to Indonesian
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<ChatCubit>().clearChatHistory();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Hapus'), // Changed to Indonesian
              ),
            ],
          ),
    );
  }
}
