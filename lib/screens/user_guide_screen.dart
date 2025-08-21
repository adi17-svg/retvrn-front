import 'package:flutter/material.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  final List<Map<String, dynamic>> spiralLevels = const [
    {
      "title": "Beige",
      "description":
          "Survival is everything. Basic needs, instincts, and safety. No complex thinking.",
      "color": Color(0xFFEEE0CB),
    },
    {
      "title": "Purple",
      "description":
          "Tribal safety, magical thinking, and bonding rituals. Loyalty to group norms.",
      "color": Color(0xFFB19CD9),
    },
    {
      "title": "Red",
      "description":
          "Power-driven, assertive, impulsive. Might is right. Egocentric leadership.",
      "color": Color(0xFFD32F2F),
    },
    {
      "title": "Blue",
      "description":
          "Order, rules, and purpose. Religious or moral codes. Sacrifice for the greater good.",
      "color": Color(0xFF1976D2),
    },
    {
      "title": "Orange",
      "description":
          "Achievement, rationality, progress. Focus on success, independence, capitalism.",
      "color": Color(0xFFFF9800),
    },
    {
      "title": "Green",
      "description":
          "Community, harmony, and empathy. Anti-hierarchy. Focus on equality and connection.",
      "color": Color(0xFF4CAF50),
    },
    {
      "title": "Yellow",
      "description":
          "Integrative thinking. Systemic awareness. Accepts complexity and paradox.",
      "color": Color(0xFFFFEB3B),
    },
    {
      "title": "Turquoise",
      "description":
          "Holistic, spiritual unity. Global consciousness. Intuition merges with rationality.",
      "color": Color(0xFF40E0D0),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiral Dynamics Guide'),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 📌 Intro explanation box
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: isDark ? Colors.grey[900] : Colors.deepPurple[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Spiral Dynamics is useful because it helps you:\n\n"
                "• Understand yourself – know what drives you now.\n\n"
                "• Understand others – reduce conflict, build empathy.\n\n"
                "• Make better choices – align life with your values.\n\n"
                "• Grow – move consciously to higher stages.\n\n"
                "👉 It’s basically a map for personal growth and better relationships.",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),

          // 📌 Spiral levels list
          ...spiralLevels.map((level) {
            final Color cardColor = level["color"];

            return Card(
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level["title"],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      level["description"],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
