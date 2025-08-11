// import 'dart:ui';
// import 'package:flutter/material.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class UserGuideScreen extends StatelessWidget {
//   const UserGuideScreen({super.key});

//   final levels = const [
//     {
//       "title": "1. Beige – Survival",
//       "color": Colors.brown,
//       "description":
//           "Focus is on basic survival. Food, water, shelter. No social structure, only instincts.",
//     },
//     {
//       "title": "2. Purple – Tribal/Magic",
//       "color": Colors.deepPurple,
//       "description":
//           "Group safety through rituals, traditions, and loyalty. Think tribes, family bonding, superstition.",
//     },
//     {
//       "title": "3. Red – Power/Warrior",
//       "color": Colors.redAccent,
//       "description":
//           "Ego-centric, might-makes-right. Assertiveness, dominance, survival of the strongest.",
//     },
//     {
//       "title": "4. Blue – Order/Duty",
//       "color": Colors.blue,
//       "description":
//           "Structure, rules, morality. Religious law, discipline, stability, following authority.",
//     },
//     {
//       "title": "5. Orange – Success/Achievement",
//       "color": Colors.orange,
//       "description":
//           "Rationality, strategy, capitalism. Personal achievement, science, goals, innovation.",
//     },
//     {
//       "title": "6. Green – Community/Equality",
//       "color": Colors.green,
//       "description":
//           "Harmony, empathy, inclusion. Feelings over logic. Social justice, eco-awareness, sharing.",
//     },
//     {
//       "title": "7. Yellow – Integration/Systemic",
//       "color": Colors.amber,
//       "description":
//           "Flexible, big-picture thinking. Interconnected systems, curiosity, learning without ego.",
//     },
//     {
//       "title": "8. Turquoise – Holistic/Global",
//       "color": Colors.teal,
//       "description":
//           "Global unity, consciousness, deep compassion. Collective purpose, spiritual integration.",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ValueListenableBuilder(
//         valueListenable: selectedBgIndex,
//         builder: (_, index, __) {
//           return Stack(
//             children: [
//               Image.asset(
//                 bgList[index],
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: double.infinity,
//               ),
//               Container(color: Colors.black.withOpacity(0.4)),
//               SafeArea(
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         const BackButton(color: Colors.white),
//                         const SizedBox(width: 8),
//                         const Text(
//                           "Spiral Dynamics Guide",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: Text(
//                         "🌈 These are the Spiral Dynamics levels that describe human growth and worldview stages.",
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 14,
//                           fontStyle: FontStyle.italic,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Expanded(
//                       child: ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: levels.length,
//                         itemBuilder: (context, i) {
//                           final level = levels[i];
//                           return GlassLevelCard(
//                             title: level['title'] as String,
//                             description: level['description'] as String,
//                             color: level['color'] as Color,
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class GlassLevelCard extends StatelessWidget {
//   final String title;
//   final String description;
//   final Color color;

//   const GlassLevelCard({
//     super.key,
//     required this.title,
//     required this.description,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(18),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 10),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(18),
//             border: Border.all(color: color.withOpacity(0.6), width: 2),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 description,
//                 style: const TextStyle(color: Colors.white, fontSize: 15),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiral Dynamics Guide'),
        centerTitle: true,
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: spiralLevels.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          final level = spiralLevels[index];
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
                      color: Colors.black87, // Fixed color for all titles
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    level["description"],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87, // Fixed color for all descriptions
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
