import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../models/chat_message.dart';
import 'supabase_service.dart';

class ChatService extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

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

  // Fetch chat history from Supabase
  Future<void> fetchChatHistory() async {
    _setLoading(true);
    _clearError();

    try {
      final userId = _supabaseService.client.auth.currentUser?.id;

      if (userId == null) {
        // If no user is logged in, use default chat history or empty
        _messages = _getDefaultChatHistory();
        notifyListeners();
        return;
      }

      final response = await _supabaseService.client
          .from('chat_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final messages =
          response.map((message) => ChatMessage.fromJson(message)).toList();

      _messages = messages;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load chat history: $e');
      // Fallback to default chat history
      _messages = _getDefaultChatHistory();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Send a text message to the AI assistant
  Future<void> sendTextMessage(String content) async {
    _setLoading(true);
    _clearError();

    try {
      final userId = _supabaseService.client.auth.currentUser?.id;

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

      // Save user message to database if user is logged in
      if (userId != null) {
        await _supabaseService.client.from('chat_messages').insert({
          'id': userMessage.id,
          'user_id': userId,
          'content': content,
          'type': 'text',
          'sender': 'user',
          'created_at': userMessage.timestamp.toIso8601String(),
        });
      }
      // Generate AI response (simple mock response for now)
      final aiResponse = _generateAIResponse(content);

      // Create AI response message
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_ai',
        content: aiResponse,
        type: MessageType.text,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      // Add AI message to the list
      _messages.add(aiMessage);
      notifyListeners();

      // Save AI message to database if user is logged in
      if (userId != null) {
        await _supabaseService.client.from('chat_messages').insert({
          'id': aiMessage.id,
          'user_id': userId,
          'content': aiResponse,
          'type': 'text',
          'sender': 'assistant',
          'created_at': aiMessage.timestamp.toIso8601String(),
        });
      }
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
      final userId = _supabaseService.client.auth.currentUser?.id;

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

      // Upload image to Supabase storage
      final imagePath =
          'chat_images/${userId ?? 'anonymous'}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await _supabaseService.client.storage
          .from('chat-images')
          .uploadBinary(imagePath, Uint8List.fromList(imageBytes));

      final imageUrl = _supabaseService.client.storage
          .from('chat-images')
          .getPublicUrl(imagePath);

      // Update user message with the image URL
      final updatedUserMessage = userMessage.copyWith(
        content: 'Image',
        imageUrl: imageUrl,
      );

      // Replace temporary message with updated one
      final index = _messages.indexWhere((m) => m.id == userMessage.id);
      if (index != -1) {
        _messages[index] = updatedUserMessage;
      }

      // Save user message to database if user is logged in
      if (userId != null) {
        await _supabaseService.client.from('chat_messages').insert({
          'id': userMessage.id,
          'user_id': userId,
          'content': 'Image',
          'type': 'image',
          'sender': 'user',
          'image_url': imageUrl,
          'created_at': userMessage.timestamp.toIso8601String(),
        });
      }
      // Generate AI response for image
      final aiResponse =
          'Saya melihat gambar yang Anda kirim. Ini terlihat seperti hidangan Indonesia yang sangat lezat! Apakah ada yang bisa saya bantu terkait resep atau masakan ini?';

      // Create AI response message
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_ai',
        content: aiResponse,
        type: MessageType.text,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      // Add AI message to the list
      _messages.add(aiMessage);
      notifyListeners();

      // Save AI message to database if user is logged in
      if (userId != null) {
        await _supabaseService.client.from('chat_messages').insert({
          'id': aiMessage.id,
          'user_id': userId,
          'content': aiResponse,
          'type': 'text',
          'sender': 'assistant',
          'created_at': aiMessage.timestamp.toIso8601String(),
        });
      }
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

      // Update rating in database
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId != null) {
        await _supabaseService.client
            .from('chat_messages')
            .update({
              'is_rated_positive': isPositive ? true : null,
              'is_rated_negative': isPositive ? null : true,
            })
            .eq('id', messageId)
            .eq('user_id', userId);
      }
    } catch (e) {
      _setError('Failed to rate message: $e');
    }
  }

  // Clear chat history
  Future<void> clearChatHistory() async {
    _setLoading(true);
    _clearError();

    try {
      final userId = _supabaseService.client.auth.currentUser?.id;

      if (userId != null) {
        await _supabaseService.client
            .from('chat_messages')
            .delete()
            .eq('user_id', userId);
      }

      _messages = [];
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear chat history: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate AI response based on user input
  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('rendang')) {
      return 'Rendang adalah masakan daging yang berasal dari Minangkabau, Sumatera Barat. Rendang diolah dengan santan dan rempah-rempah hingga kering dan berwarna gelap. Ini adalah salah satu masakan terenak di dunia!';
    } else if (message.contains('nasi goreng')) {
      return 'Nasi goreng adalah makanan khas Indonesia yang sangat populer. Anda bisa menambahkan berbagai bahan seperti telur, ayam, udang, dan sayuran. Kecap manis adalah bahan kunci untuk nasi goreng yang otentik.';
    } else if (message.contains('sambal')) {
      return 'Ada banyak jenis sambal di Indonesia, seperti sambal terasi, sambal matah dari Bali, dan sambal dabu-dabu dari Manado. Masing-masing memiliki cita rasa unik dan pedas yang berbeda.';
    } else if (message.contains('resep') || message.contains('recipe')) {
      return 'Saya bisa membantu Anda mencari resep masakan Indonesia! Apa jenis masakan yang ingin Anda buat? Saya punya banyak resep mulai dari makanan tradisional hingga modern.';
    } else if (message.contains('bahan') || message.contains('ingredient')) {
      return 'Untuk masakan Indonesia, bahan-bahan dasar yang sering digunakan antara lain bawang merah, bawang putih, cabai, kemiri, jahe, lengkuas, kunyit, dan santan. Apakah ada bahan tertentu yang ingin Anda ketahui?';
    } else {
      return 'Terima kasih atas pesan Anda! Saya siap membantu dengan pertanyaan seputar masakan Indonesia, resep, bahan makanan, atau tips memasak. Ada yang bisa saya bantu?';
    }
  }

  // Default chat history for new users
  List<ChatMessage> _getDefaultChatHistory() {
    return [
      ChatMessage(
        id: '1',
        content:
            'Selamat datang di Rasain Chat! Saya adalah asisten AI yang siap membantu Anda dengan masakan Indonesia. Ada yang bisa saya bantu?',
        type: MessageType.text,
        sender: MessageSender.ai,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
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
