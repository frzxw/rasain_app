enum MessageType {
  text,
  image,
}

enum MessageSender {
  user,
  ai,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final MessageSender sender;
  final DateTime timestamp;
  final String? imageUrl;
  final bool? isRatedPositive;
  final bool? isRatedNegative;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.sender,
    required this.timestamp,
    this.imageUrl,
    this.isRatedPositive,
    this.isRatedNegative,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.byName(json['type']),
      sender: MessageSender.values.byName(json['sender']),
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['image_url'],
      isRatedPositive: json['is_rated_positive'],
      isRatedNegative: json['is_rated_negative'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'image_url': imageUrl,
      'is_rated_positive': isRatedPositive,
      'is_rated_negative': isRatedNegative,
    };
  }

  // Create a copy of chat message with modifications
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageSender? sender,
    DateTime? timestamp,
    String? imageUrl,
    bool? isRatedPositive,
    bool? isRatedNegative,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      isRatedPositive: isRatedPositive ?? this.isRatedPositive,
      isRatedNegative: isRatedNegative ?? this.isRatedNegative,
    );
  }
}
