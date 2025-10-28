import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();

  /// Initialize the service (e.g. set up language, speech rate)
  Future<void> initialize() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
  }

  /// Mock voice-to-text listening
  Future<void> startListening({required Function(String) onResult}) async {
    // Simulate listening delay and response
    await Future.delayed(const Duration(seconds: 2));
    onResult('Patient is feeling dizzy and has a headache.');
  }

  /// Stop listening (placeholder)
  Future<void> stopListening() async {
    // In a real app, stop microphone input here
  }

  /// Clean up TTS resources
  void dispose() {
    _flutterTts.stop();
  }
}
