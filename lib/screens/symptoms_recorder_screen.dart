import 'package:care_q/screens/vital_signs_screen.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../config/theme.dart';
import '../services/voice_service.dart';

class SymptomsRecorderScreen extends StatefulWidget {
  const SymptomsRecorderScreen({super.key, required String patientId});

  @override
  State<SymptomsRecorderScreen> createState() => _SymptomsRecorderScreenState();
}

class _SymptomsRecorderScreenState extends State<SymptomsRecorderScreen> {
  final VoiceService _voiceService = VoiceService();
  String _recordedText = '';
  bool _isListening = false;
  double _painLevel = 5;

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: PremiumTheme.purpleGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Main Content Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: PremiumTheme.backgroundLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Let's record your",
                          style: TextStyle(
                            fontSize: 24,
                            color: PremiumTheme.textGray,
                          ),
                        ),
                        const Text(
                          'symptoms',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: PremiumTheme.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Voice Recording Area with 3D Doctor
                        Center(
                          child: Column(
                            children: [
                              // Doctor Avatar
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: PremiumTheme.cardShadow,
                                ),
                                child: const Center(
                                  child: Text(
                                    '👨‍⚕️',
                                    style: TextStyle(fontSize: 80),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Microphone Button
                              AvatarGlow(
                                animate: _isListening,
                                glowColor: PremiumTheme.primaryPurple,
                                duration: const Duration(milliseconds: 2000),
                                repeat: true,
                                child: GestureDetector(
                                  onTap: _toggleListening,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: _isListening
                                          ? PremiumTheme.pinkGradient
                                          : PremiumTheme.purpleGradient,
                                      shape: BoxShape.circle,
                                      boxShadow: PremiumTheme.buttonShadow,
                                    ),
                                    child: Icon(
                                      _isListening ? Icons.mic : Icons.mic_none,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Status Text
                        Center(
                          child: Text(
                            _isListening ? 'Listening...' : 'Tap to speak',
                            style: TextStyle(
                              fontSize: 18,
                              color: _isListening
                                  ? PremiumTheme.primaryPurple
                                  : PremiumTheme.textGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Recorded Text Display
                        if (_recordedText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: PremiumTheme.cardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      color: PremiumTheme.primaryPurple,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Your symptoms:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: PremiumTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _recordedText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: PremiumTheme.textDark,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Pain Scale
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: PremiumTheme.cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'On scale of 1-10, rate',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Text(
                                'how do you feel today?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: PremiumTheme.primaryPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Emoji Scale
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('😊', style: TextStyle(fontSize: 28)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: PremiumTheme.purpleGradient,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_painLevel.round()}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Text('😣', style: TextStyle(fontSize: 28)),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Slider
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: PremiumTheme.primaryPurple,
                                  inactiveTrackColor: PremiumTheme.primaryPurple.withOpacity(0.2),
                                  thumbColor: PremiumTheme.primaryPurple,
                                  overlayColor: PremiumTheme.primaryPurple.withOpacity(0.2),
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                                  trackHeight: 6,
                                ),
                                child: Slider(
                                  value: _painLevel,
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  onChanged: (value) {
                                    setState(() => _painLevel = value);
                                  },
                                ),
                              ),

                              // Scale Labels
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(10, (index) {
                                  return Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _painLevel.round() == index + 1
                                          ? PremiumTheme.primaryPurple
                                          : PremiumTheme.textGray,
                                      fontWeight: _painLevel.round() == index + 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const VitalSignsScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PremiumTheme.primaryPurple,
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _voiceService.startListening(
        onResult: (text) {
          setState(() {
            _recordedText = text;
            _isListening = false;
          });
        },
      );
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
