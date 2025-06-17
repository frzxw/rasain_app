import 'package:equatable/equatable.dart';
import '../../models/chat_message.dart';

enum ChatStatus { initial, loading, loaded, sending, error }

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final ChatStatus status;
  final String? errorMessage;
  final bool isProcessingImage;

  const ChatState({
    this.messages = const [],
    this.status = ChatStatus.initial,
    this.errorMessage,
    this.isProcessingImage = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    ChatStatus? status,
    String? errorMessage,
    bool? isProcessingImage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isProcessingImage: isProcessingImage ?? this.isProcessingImage,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    status,
    errorMessage,
    isProcessingImage,
  ];
}
