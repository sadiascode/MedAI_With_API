import 'dart:async';
import 'dart:io';
import 'package:care_agent/features/chat/screen/chatdetails_screen.dart';
import 'package:care_agent/features/chat/widget/custom_text.dart';
import 'package:care_agent/features/chat/services/chat_service.dart';
import 'package:care_agent/features/chat/services/voice_chat_service.dart';
import 'package:care_agent/features/chat/models/chat_model.dart';
import 'package:care_agent/features/chat/models/chat_prescription_model.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get_storage/get_storage.dart';
import '../../auth/services/auth_service.dart';
import '../../../common/app_shell.dart';
import '../services/voice_recording_service.dart';

class ChatsScreenContent extends StatefulWidget {
  final bool isActive;
  const ChatsScreenContent({super.key, this.isActive = false});

  @override
  State<ChatsScreenContent> createState() => _ChatsScreenContentState();
}

class _ChatsScreenContentState extends State<ChatsScreenContent> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showPlaceholderImage = true;
  String? _currentlyPlayingPath;
  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription? _playerStateSubscription;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    // Ensure the service is initialized for any permissions if needed
    VoiceRecordingService.initialize();
    
    _playerStateSubscription = VoiceRecordingService.playerStateStream.listen((state) {
      if (mounted) {
        print(' Player State Changed: $state');
        setState(() {
          _playerState = state;
          if (state == PlayerState.completed || state == PlayerState.stopped) {
            _currentlyPlayingPath = null;
            print('   - Playback stopped/completed, clearing path.');
          }
        });
      }
    });

    _fetchChatHistory();
  }

  @override
  void didUpdateWidget(covariant ChatsScreenContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh history if tab becomes active and we have no messages yet
    if (widget.isActive && !oldWidget.isActive && _messages.isEmpty) {
      _fetchChatHistory();
    }
  }

  Future<void> _fetchChatHistory() async {
    if (_isLoadingHistory) return;
    
    print('🔄 Fetching chat history...');
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final currentUserId = await _getCurrentUserId();
      final history = await ChatService.getChatHistory(userId: currentUserId);
      
      if (mounted) {
        final List<Map<String, dynamic>> historyMessages = [];
        
        final sortedConversations = history.conversations.reversed.toList();
        for (var conversation in sortedConversations) {
          for (var messagePair in conversation.messages) {
            if (messagePair.user != null) {
              historyMessages.add({
                'sender': 'user',
                'type': messagePair.user!.messageType,
                'text': messagePair.user!.textContent,
                'imagePath': messagePair.user!.imageFileUrl,
                'audioPath': messagePair.user!.voiceFileUrl,
                'createdAt': messagePair.user!.createdAt,
              });
            }
            if (messagePair.ai != null) {
              historyMessages.add({
                'sender': 'bot',
                'type': messagePair.ai!.messageType,
                'text': messagePair.ai!.textContent,
                'voiceUrl': messagePair.ai!.voiceFileUrl,
                'imagePath': messagePair.ai!.imageFileUrl,
                'createdAt': messagePair.ai!.createdAt,
              });
            }
          }
        }
        
        print('✅ Fetched ${historyMessages.length} history messages');

        setState(() {
          if (historyMessages.isNotEmpty) {
            _messages.clear();
            _messages.addAll(historyMessages);
            _showPlaceholderImage = false;
          } else {
            // Keep placeholder if no history
            _showPlaceholderImage = _messages.isEmpty;
          }
          _isLoadingHistory = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('❌ Error fetching chat history: $e');
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _showPlaceholderImage = false;
      _messageController.clear();
      _messages.add({'sender': 'bot', 'text': 'Typing...', 'isTyping': true});
    });

    try {
      final currentUserId = await _getCurrentUserId();
      final authToken = await _getCurrentAuthToken();
      final ChatModel response = await ChatService.sendMessage(text, currentUserId, token: authToken);

      setState(() {
        _messages.removeWhere((element) => element['isTyping'] == true);
        _messages.add({
          'sender': 'bot',
          'text': response.response ?? 'Sorry, I process your message.',
          'type': response.messageType ?? 'text',
          'conversationId': response.conversationId,
        });
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((msg) => msg['isTyping'] == true);
        _messages.add({
          'sender': 'bot',
          'text': 'Something went wrong. Please try again.',
          'type': 'error',
        });
      });
    }
    _scrollToBottom();
  }

  Future<int> _getCurrentUserId() async {
    if (AuthService.currentUserId != 0) {
      return AuthService.currentUserId;
    }
    final box = GetStorage();
    final savedId = box.read('user_id');
    if (savedId != null && savedId is int) {
      return savedId;
    }
    return 0;
  }

  Future<String> _getCurrentAuthToken() async {
    final box = GetStorage();
    return box.read('access_token') ?? '';
  }

  Future<void> _sendVoiceMessage(Map<String, dynamic> voiceData) async {
    setState(() {
      _messages.add({
        'sender': 'user',
        'type': 'voice',
        'audioPath': voiceData['audioPath'],
        'duration': voiceData['duration'],
      });
      _showPlaceholderImage = false;
    });
    _scrollToBottom();

    try {
      final currentUserId = await _getCurrentUserId();
      final response = await VoiceChatService.sendVoiceMessage(
        audioPath: voiceData['audioPath'],
        userId: currentUserId,
      );

      if (response.messageType == 'voice') {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'type': 'voice',
            'voiceUrl': response.voiceUrl,
            'text': response.response,
            'conversationId': response.conversationId,
            'createdAt': response.createdAt,
          });
        });

        if (response.voiceUrl != null && response.voiceUrl!.isNotEmpty) {
          _playVoiceMessage(null, voiceUrl: response.voiceUrl);
        }
      } else {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'type': 'text',
            'text': response.response,
            'conversationId': response.conversationId,
            'createdAt': response.createdAt,
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'type': 'error',
          'text': 'Failed to send voice message. Please try again.',
        });
      });
    }
    _scrollToBottom();
  }

  Future<void> _sendImageMessage(File imageFile) async {
    final int messageIndex = _messages.length;
    setState(() {
      _messages.add({
        'sender': 'user',
        'type': 'image',
        'imagePath': imageFile.path,
        'isLoading': true,
      });
      _showPlaceholderImage = false;
    });
    _scrollToBottom();

    try {
      final currentUserId = await _getCurrentUserId();
      final response = await ChatService.sendPrescriptionImage(
        imageFile: imageFile,
        userId: currentUserId,
      );

      setState(() {
        _messages[messageIndex]['isLoading'] = false;
      });

      // Parse the response and navigate to ChatdetailsScreen
      final prescriptionModel = ChatPrescriptionModel.fromJson(response);
      
      if (mounted && prescriptionModel.data.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatdetailsScreen(prescriptionData: prescriptionModel),
          ),
        );
      } else {
        // Fallback for empty data or unexpected format
        setState(() {
          _messages.add({
            'sender': 'bot',
            'text': prescriptionModel.response ?? response['response'] ?? 'Analysis complete, but no prescription data was found.',
            'type': 'text',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages[messageIndex]['isLoading'] = false;
        _messages.add({
          'sender': 'bot',
          'type': 'error',
          'text': 'Failed to analyze prescription. Please try again.',
        });
      });
    }
    _scrollToBottom();
  }

  Future<void> _playVoiceMessage(String? audioPath, {String? voiceUrl}) async {
    try {
      final String targetPath = voiceUrl ?? audioPath ?? '';
      if (targetPath.isEmpty) return;

      final bool isUrl = targetPath.startsWith('http');

      if (_currentlyPlayingPath == targetPath) {
        // Toggle: If playing, stop it. If stopped/paused, play it.
        if (_playerState == PlayerState.playing) {
          await VoiceRecordingService.stopAudio();
          setState(() {
            _playerState = PlayerState.stopped;
            _currentlyPlayingPath = null;
          });
        } else {
          await VoiceRecordingService.playAudio(targetPath, isUrl: isUrl);
        }
      } else {
        // Switch: Stop current and play new
        await VoiceRecordingService.stopAudio();
        await VoiceRecordingService.playAudio(targetPath, isUrl: isUrl);
        setState(() {
          _currentlyPlayingPath = targetPath;
        });
      }
    } catch (e) {
      print(' Error playing voice message: $e');
      _showErrorSnackBar('Failed to play voice message');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF7),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Chat",
          style: TextStyle(
            color: Color(0xffE0712D),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Color(0xffE0712D)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatdetailsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoadingHistory)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchChatHistory,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length + ((_showPlaceholderImage && !_isLoadingHistory) ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_showPlaceholderImage && !_isLoadingHistory && index == 0) {
                    return Center(
                      child: Image.asset(
                        'assets/text.png',
                        height: 300,
                        width: 300,
                      ),
                    );
                  }

                final msgIndex = (_showPlaceholderImage && !_isLoadingHistory) ? index - 1 : index;
                final msg = _messages[msgIndex];
                final isUser = msg['sender'] == 'user';
                final messageType = msg['type'] ?? 'text';
                final isTyping = msg['isTyping'] == true;


                if (isTyping) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "Typing...",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                }

                final isPlaying = _currentlyPlayingPath == (msg['voiceUrl'] ?? msg['audioPath']) && _playerState == PlayerState.playing;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: messageType == 'voice' 
                        ? () => _playVoiceMessage(msg['audioPath'], voiceUrl: msg['voiceUrl'])
                        : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFFE0712D) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isUser ? null : Border.all(color: Colors.grey.shade300),
                        boxShadow: isPlaying 
                            ? [BoxShadow(color: const Color(0xFFE0712D).withOpacity(0.3), blurRadius: 8, spreadRadius: 2)] 
                            : null,
                      ),
                      child: messageType == 'voice'
                          ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.white.withOpacity(0.2) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPlaying ? Icons.stop : Icons.play_arrow,
                                    color: isUser ? Colors.white : const Color(0xFFE0712D),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    msg['duration'] != null && msg['duration'] != '?'
                                        ? "Voice (${msg['duration']}s)"
                                        : "Voice Message",
                                    style: TextStyle(
                                      color: isUser ? Colors.white : Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : messageType == 'image'
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: msg['imagePath'] != null && msg['imagePath'].toString().startsWith('http')
                                      ? Image.network(
                                          msg['imagePath'],
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 200,
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.error),
                                          ),
                                        )
                                      : Image.file(
                                          File(msg['imagePath'] ?? ''),
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                    ),
                                    if (msg['isLoading'] == true) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Analyzing...",
                                            style: TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                )
                              : Text(
                                  msg['text'] ?? '',
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black,
                                  ),
                                ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CustomText(
                messageController: _messageController,
                onSend: (text) {
                  _sendMessage(text);
                  _scrollToBottom();
                },
                onVoiceRecorded: (voiceData) {
                  _sendVoiceMessage(voiceData);
                },
                onImageCaptured: (imageFile) {
                  _sendImageMessage(imageFile);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(initialIndex: 3);
  }
}