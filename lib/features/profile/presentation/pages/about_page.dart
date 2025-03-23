import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Near Me',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Near Me is a social networking app designed to bring campus students closer in real-time! Whether you want to chat, share memes, or see who's nearby, Near Me makes it seamless with a smooth and modern UI.",
              style: TextStyle(fontSize: 16),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieBuilder.asset(
                    width: 200,
                    repeat: true,
                    isDarkMode
                        ? "assets/boy-darkmode.mp4.lottie.json"
                        : "assets/Boy going to school.mp4.lottie.json"),
                SizedBox(
                  width: 20,
                ),
                LottieBuilder.asset(
                  isDarkMode
                      ? "assets/girl-darkmode.mp4.lottie.json"
                      : "assets/School Girl Running.mp4.lottie.json",
                  width: 200,
                )
              ],
            ),
            const SizedBox(height: 20),
            _buildFeature('🌍 Real-time Nearby Users',
                'Instantly see students around you using the app.'),
            _buildFeature('💬 Chat in Real-time',
                'Fast and smooth messaging experience.'),
            _buildFeature('😂 Meme Hub', 'Share and enjoy trending memes.'),
            _buildFeature('🗺 Connect on Campus',
                'Find and interact with students at your university.'),
            _buildFeature('🔐 Secure & Fast',
                'Ensures a safe and private experience for students.'),
            const SizedBox(height: 20),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(FontAwesomeIcons.telegram,
                    color: Colors.blueAccent, size: 24),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join our Telegram communities:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '📢 Join @JmbTalks to stay updated!',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '😂 Join @CNCSMEMES for memes!',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
