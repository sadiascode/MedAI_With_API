import 'dart:async';
import 'package:care_agent/features/chat/screen/chatdetails_screen.dart';
import 'package:care_agent/features/chat/widget/custom_text.dart';
import 'package:care_agent/features/chat/services/chat_service.dart';
import 'package:care_agent/features/chat/services/voice_chat_service.dart';
import 'package:care_agent/features/chat/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get_storage/get_storage.dart';
import '../../auth/services/auth_service.dart';
import '../../../common/app_shell.dart';
import '../services/voice_recording_service.dart';

class ChatsScreenContent extends StatefulWidget {
  const ChatsScreenContent({super.key});

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

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = VoiceRecordingService.playerStateStream?.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
          if (state == PlayerState.completed || state == PlayerState.stopped) {
            _currentlyPlayingPath = null;
          }
        });
      }
    });
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
    return AuthService.currentUserId;
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

  Future<void> _playVoiceMessage(String? audioPath, {String? voiceUrl}) async {
    try {
      final String targetPath = voiceUrl ?? audioPath ?? '';
      if (targetPath.isEmpty) return;

      if (_currentlyPlayingPath == targetPath) {
        if (_playerState == PlayerState.playing) {
          await VoiceRecordingService.pauseAudio();
        } else if (_playerState == PlayerState.paused) {
          await VoiceRecordingService.resumeAudio();
        } else {
          await VoiceRecordingService.playAudio(targetPath, isUrl: voiceUrl != null);
        }
      } else {
        await VoiceRecordingService.stopAudio();
        await VoiceRecordingService.playAudio(targetPath, isUrl: voiceUrl != null);
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
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length + (_showPlaceholderImage ? 1 : 0),
              itemBuilder: (context, index) {
                if (_showPlaceholderImage && index == 0) {
                  return Center(
                    child: Image.asset(
                      'assets/text.png',
                      height: 300,
                      width: 300,
                    ),
                  );
                }

                final msgIndex = _showPlaceholderImage ? index - 1 : index;
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

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFE0712D) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isUser ? null : Border.all(color: Colors.grey.shade300),
                    ),
                    child: messageType == 'voice'
                        ? GestureDetector(
                      onTap: () {
                        print(' Voice message tapped!');
                        print('   - Audio path: ${msg['audioPath']}');
                        print('   - Voice URL: ${msg['voiceUrl']}');
                        print('   - Message data: $msg');
                        _playVoiceMessage(msg['audioPath'], voiceUrl: msg['voiceUrl']);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.white.withOpacity(0.2) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (_currentlyPlayingPath == (msg['voiceUrl'] ?? msg['audioPath']) && _playerState == PlayerState.playing)
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: isUser ? Colors.white : const Color(0xFFE0712D),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              " Voice (${msg['duration'] ?? '?'}s)",
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        : Text(
                      msg['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
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