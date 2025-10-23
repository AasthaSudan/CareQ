import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Quick Emergency Triage",
      "desc": "Sort and manage patients based on urgency using AI-powered predictions.",
      "animation": "assets/animations/triage.json"
    },
    {
      "title": "Real-Time Patient Monitoring",
      "desc": "Track vitals, alert staff, and ensure quick responses to critical cases.",
      "animation": "assets/animations/monitor.json"
    },
    {
      "title": "Efficient Resource Allocation",
      "desc": "Smart bed assignment and doctor allocation for faster treatment.",
      "animation": "assets/animations/hospital.json"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => currentPage = index),
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final data = pages[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(data["animation"]!, height: 250),
                      const SizedBox(height: 20),
                      Text(
                        data["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data["desc"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ✅ Bottom Navigation (Dots + Button)
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: currentPage == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentPage == index ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (currentPage == pages.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(currentPage == pages.length - 1
                      ? "Get Started"
                      : "Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
