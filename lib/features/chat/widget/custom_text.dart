import 'package:care_agent/features/chat/widget/action_input_bar_widget.dart';
import 'package:flutter/material.dart';

class CustomText extends StatefulWidget {
  final TextEditingController messageController;
  final Function(String) onSend;
  final Function(Map<String, dynamic>)? onVoiceRecorded;

  const CustomText({
    super.key,
    required this.messageController,
    required this.onSend,
    this.onVoiceRecorded,
  });

  @override
  State<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  Map<String, dynamic>? _stagedRecording;

  void _handleSend() {
    if (_stagedRecording != null) {
      if (widget.onVoiceRecorded != null) {
        widget.onVoiceRecorded!(_stagedRecording!);
      }
      setState(() {
        _stagedRecording = null;
      });
    } else if (widget.messageController.text.trim().isNotEmpty) {
      widget.onSend(widget.messageController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0712D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE0712D)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 11),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xffFFFAF7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _stagedRecording != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.mic, color: Color(0xFFE67E22)),
                              const SizedBox(width: 8),
                              Text(
                                "Voice Recording (${_stagedRecording!['duration']}s)",
                                style: const TextStyle(color: Color(0xFFE67E22), fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _stagedRecording = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      : TextField(
                          controller: widget.messageController,
                          decoration: const InputDecoration(
                            hintText: 'Chat with MedAI.....',
                            hintStyle: TextStyle(color: Color(0xFFE67E22), fontSize: 15),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                ),
                IconButton(
                  onPressed: _handleSend,
                  icon: const Icon(Icons.send, color: Color(0xFFE67E22), size: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ActionInputBarWidget(
            onRecordingComplete: (voiceData) {
              setState(() {
                _stagedRecording = voiceData;
              });
            },
          ),
        ],
      ),
    );
  }
}