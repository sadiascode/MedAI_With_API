import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecordingService {
  static AudioRecorder? _audioRecorder;
  static AudioPlayer? _audioPlayer;
  static String? _currentRecordingPath;
  static bool _isInitialized = false;

  static Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;


      _audioRecorder = AudioRecorder();
      _audioPlayer = AudioPlayer();


      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print('Microphone permission denied: $status');
        return false;
      }

      _isInitialized = true;
      print(' VoiceRecordingService initialized');
      return true;
    } catch (e) {
      print(' Error initializing VoiceRecordingService: $e');
      return false;
    }
  }

  static Future<String?> startRecording() async {
    try {
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) return null;
      }

      if (_audioRecorder == null) {
        print(' Audio recorder not initialized');
        return null;
      }

      if (await _audioRecorder!.isRecording()) {
        print(' Already recording');
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'voice_recording_$timestamp.m4a';
      _currentRecordingPath = path.join(tempDir.path, fileName);

      print(' Starting recording to: $_currentRecordingPath');

      await _audioRecorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final isRecording = await _audioRecorder!.isRecording();
      if (!isRecording) {
        print(' Failed to start recording');
        _currentRecordingPath = null;
        return null;
      }

      print('Recording started: $_currentRecordingPath');
      return _currentRecordingPath;
    } catch (e) {
      print(' Error starting recording: $e');
      _currentRecordingPath = null;
      return null;
    }
  }

  static Future<String?> stopRecording() async {
    try {
      if (_audioRecorder == null) return null;

      final isRecording = await _audioRecorder!.isRecording();
      if (!isRecording) return null;

      print(' Stopping recording...');
      final path = await _audioRecorder!.stop();
      
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final size = await file.length();
          if (size < 100) {
            print(' Recording too short or empty');
            await file.delete();
            return null;
          }
          print(' Recording stopped successfully. Size: $size bytes');
          return path;
        }
      }
      return null;
    } catch (e) {
      print(' Error stopping recording: $e');
      return null;
    }
  }

  static Future<void> cancelRecording() async {
    try {
      if (_audioRecorder == null) return;
      final path = await _audioRecorder!.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          print(' Deleted incomplete recording: $path');
        }
      }
      _currentRecordingPath = null;
      print(' Recording canceled');
    } catch (e) {
      print(' Error canceling recording: $e');
    }
  }

  static Future<void> playAudio(String path, {bool isUrl = false}) async {
    try {
      if (_audioPlayer == null) return;
      
      print(' Attempting to play voice message: $path');
      
      if (isUrl) {
        await _audioPlayer!.play(UrlSource(path));
      } else {
        final file = File(path);
        if (await file.exists()) {
          await _audioPlayer!.play(DeviceFileSource(path));
        } else {
          print(' Error: Audio file does not exist at $path');
        }
      }
    } catch (e) {
      print(' Error playing audio: $e');
    }
  }

  static Future<void> pauseAudio() async {
    await _audioPlayer?.pause();
  }

  static Future<void> resumeAudio() async {
    await _audioPlayer?.resume();
  }

  static Future<void> stopAudio() async {
    await _audioPlayer?.stop();
  }

  static Stream<PlayerState>? get playerStateStream => _audioPlayer?.onPlayerStateChanged;

  static Future<bool> isRecording() async {
    try {
      return _audioRecorder != null && await _audioRecorder!.isRecording();
    } catch (e) {
      print(' Error checking recording status: $e');
      return false;
    }
  }

  static Future<void> cleanupTempFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print(' Cleaned up temporary file: $filePath');
      }
    } catch (e) {
      print(' Failed to cleanup temporary file: $e');
    }
  }

  static void dispose() {
    try {
      _audioRecorder?.dispose();
      _audioPlayer?.dispose();
      _audioRecorder = null;
      _audioPlayer = null;
      _isInitialized = false;
      print(' VoiceRecordingService disposed');
    } catch (e) {
      print(' Error disposing VoiceRecordingService: $e');
    }
  }
}
