import 'package:bloc/bloc.dart';
import 'dart:typed_data';
import '../../services/chat_service.dart';
import '../../models/chat_message.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService;

  ChatCubit(this._chatService) : super(const ChatState());

  // Initialize and load chat history
  Future<void> initialize() async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      await _chatService.initialize();

      emit(
        state.copyWith(
          messages: _chatService.messages,
          status: ChatStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Send a text message to the AI assistant
  Future<void> sendTextMessage(String content) async {
    if (content.trim().isEmpty) return;

    emit(state.copyWith(status: ChatStatus.sending));
    try {
      await _chatService.sendTextMessage(content);

      emit(
        state.copyWith(
          messages: _chatService.messages,
          status: ChatStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Send an image to the AI assistant for analysis
  Future<void> sendImageMessage(Uint8List imageBytes) async {
    emit(state.copyWith(status: ChatStatus.sending, isProcessingImage: true));

    try {
      // Create a file name based on timestamp
      String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _chatService.sendImageMessage(imageBytes.toList(), fileName);

      emit(
        state.copyWith(
          messages: _chatService.messages,
          status: ChatStatus.loaded,
          isProcessingImage: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: e.toString(),
          isProcessingImage: false,
        ),
      );
    }
  }

  // Rate a message from the AI assistant (positive/helpful)
  Future<void> rateMessagePositive(String messageId) async {
    try {
      await _chatService.rateMessage(messageId, true);

      emit(state.copyWith(messages: _chatService.messages));
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Rate a message from the AI assistant (negative/not helpful)
  Future<void> rateMessageNegative(String messageId) async {
    try {
      await _chatService.rateMessage(messageId, false);

      emit(state.copyWith(messages: _chatService.messages));
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Clear chat history
  Future<void> clearChatHistory() async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      await _chatService.clearChatHistory();

      emit(
        state.copyWith(
          messages: _chatService.messages,
          status: ChatStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
