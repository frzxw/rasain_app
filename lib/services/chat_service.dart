import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import 'api_service.dart';

class ChatService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize and load chat history
  Future<void> initialize() async {
    await fetchChatHistory();
  }
  
  // Fetch chat history from API
  Future<void> fetchChatHistory() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get('chat/history');
      
      final messages = (response['messages'] as List)
          .map((message) => ChatMessage.fromJson(message))
          .toList();
      
      _messages = messages;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load chat history: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Send a text message to the AI assistant
  Future<void> sendTextMessage(String content) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Create a temporary user message
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        type: MessageType.text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      );
      
      // Add user message to the list
      _messages.add(userMessage);
      notifyListeners();
      
      // Send message to API
      final response = await _apiService.post(
        'chat/message',
        body: {
          'content': content,
          'type': 'text',
        },
      );
      
      // Create AI response message
      final aiMessage = ChatMessage.fromJson(response['message']);
      
      // Add AI message to the list
      _messages.add(aiMessage);
      notifyListeners();
    } catch (e) {
      _setError('Failed to send message: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Send an image message to the AI assistant
  Future<void> sendImageMessage(List<int> imageBytes, String fileName) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Create a temporary user message with loading state
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sending image...',
        type: MessageType.image,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      );
      
      // Add user message to the list
      _messages.add(userMessage);
      notifyListeners();
      
      // Upload image
      final response = await _apiService.uploadFile(
        'chat/image',
        imageBytes,
        fileName,
        'image',
      );
      
      // Update user message with the image URL
      final updatedUserMessage = userMessage.copyWith(
        content: 'Image',
        imageUrl: response['image_url'],
      );
      
      // Replace temporary message with updated one
      final index = _messages.indexWhere((m) => m.id == userMessage.id);
      if (index != -1) {
        _messages[index] = updatedUserMessage;
      }
      
      // Create AI response message
      final aiMessage = ChatMessage.fromJson(response['message']);
      
      // Add AI message to the list
      _messages.add(aiMessage);
      notifyListeners();
    } catch (e) {
      _setError('Failed to send image: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Rate an AI message (thumbs up/down)
  Future<void> rateMessage(String messageId, bool isPositive) async {
    try {
      // Find the message
      final index = _messages.indexWhere((m) => m.id == messageId);
      
      if (index == -1) return;
      
      // Update message locally first
      final message = _messages[index];
      final updatedMessage = message.copyWith(
        isRatedPositive: isPositive ? true : null,
        isRatedNegative: isPositive ? null : true,
      );
      
      _messages[index] = updatedMessage;
      notifyListeners();
      
      // Send rating to API
      await _apiService.post(
        'chat/rate/$messageId',
        body: {'is_positive': isPositive},
      );
    } catch (e) {
      _setError('Failed to rate message: $e');
    }
  }
  
  // Clear chat history
  Future<void> clearChatHistory() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.delete('chat/history');
      
      _messages = [];
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear chat history: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String errorMessage) {
    debugPrint(errorMessage);
    _error = errorMessage;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
