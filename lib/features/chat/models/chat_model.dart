class ChatModel {
  final String? conversationId;
  final String? response;
  final String? messageType;
  final String? voiceUrl;
  final String? createdAt;

  ChatModel({
    this.conversationId,
    this.response,
    this.messageType,
    this.voiceUrl,
    this.createdAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic>? json) {
    try {
      print(' Parsing ChatModel from JSON: $json');
      

      if (json == null) {
        print(' Null JSON response received');
        return ChatModel(
          conversationId: null,
          response: 'Error: Null response received',
          messageType: 'error',
          createdAt: null,
        );
      }
      
      print(' JSON keys: ${json.keys.toList()}');
      

      final conversationId = json['conversation_id']?.toString();
      final response = json['response']?.toString() ?? '';
      final messageType = json['message_type']?.toString() ?? 'text';
      final voiceUrl = json['voice_url']?.toString();
      final createdAt = json['created_at']?.toString();
      
      print(' conversation_id: $conversationId (${json['conversation_id'].runtimeType})');
      print(' response: $response (${json['response'].runtimeType})');
      print(' message_type: $messageType (${json['message_type'].runtimeType})');
      print(' voice_url: $voiceUrl (${json['voice_url'].runtimeType})');
      print(' created_at: $createdAt (${json['created_at'].runtimeType})');
      
      // Validate required fields
      if (response.isEmpty) {
        print(' Empty response field in JSON');
        return ChatModel(
          conversationId: conversationId,
          response: 'Error: Empty response field',
          messageType: 'error',
          createdAt: createdAt,
        );
      }
      
      return ChatModel(
        conversationId: conversationId,
        response: response,
        messageType: messageType,
        voiceUrl: voiceUrl,
        createdAt: createdAt,
      );
    } catch (e) {
      print(' Error parsing ChatModel: $e');
      print(' Error Type: ${e.runtimeType}');
      print(' Stack Trace: ${StackTrace.current}');
      
      return ChatModel(
        conversationId: null,
        response: 'Error parsing response: ${e.toString()}',
        messageType: 'error',
        voiceUrl: null,
        createdAt: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'response': response,
      'message_type': messageType,
      'voice_url': voiceUrl,
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'ChatModel(conversationId: $conversationId, response: $response, messageType: $messageType, voiceUrl: $voiceUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatModel &&
        other.conversationId == conversationId &&
        other.response == response &&
        other.messageType == messageType &&
        other.voiceUrl == voiceUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return conversationId.hashCode ^
        response.hashCode ^
        messageType.hashCode ^
        voiceUrl.hashCode ^
        createdAt.hashCode;
  }
}
