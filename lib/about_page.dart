import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About FlashHanzi'),
        backgroundColor: const Color(0xFFB42F2B),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text(
              "FlashHanzi",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Learn and review Chinese characters with ease.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              "Features",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("• Spaced repetition based review system"),
            const Text("• Stroke order animations"),
            const Text("• Example sentences for context"),
            const Text("• Handwriting recognition and camera scanning"),
            const Text("• Personal notes for each character"),
            const SizedBox(height: 24),
            const Text(
              "Contact",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("For feedback or support, contact:"),
            const Text("support@flashhanzi.com"),
            const SizedBox(height: 24),
            const Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We respect your privacy. FlashHanzi does not collect or store any personal data. "
              "All your data stays on your device unless you explicitly choose to back it up or sync it. "
              "We do not sell or share your data with third parties.",
            ),
            const SizedBox(height: 24),
            const Text(
              "Terms of Use",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "FlashHanzi is provided as-is with no guarantees. By using this app, you agree not to misuse "
              "the service or attempt to reverse engineer the software.",
            ),
            const SizedBox(height: 24),
            const Text(
              "Version",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("1.0.0"),
            const SizedBox(height: 24),
            Center(
              child: Text(
                "© 2025 FlashHanzi",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
