// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<int>(
//       valueListenable: selectedBgIndex,
//       builder: (context, index, _) {
//         return Stack(
//           children: [
//             // Background image
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 500),
//               child: Image.asset(
//                 bgList[index],
//                 key: ValueKey(index),
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: double.infinity,
//               ),
//             ),
//             // Dark overlay
//             Positioned.fill(
//               child: Container(color: Colors.black.withOpacity(0.4)),
//             ),
//             // Blurred + content
//             Scaffold(
//               backgroundColor: Colors.transparent,
//               appBar: AppBar(
//                 backgroundColor: Colors.deepPurple.withOpacity(0.7),
//                 elevation: 0,
//                 title: const Text("Settings"),
//               ),
//               body: Stack(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
//                     child: ListView(
//                       children: [
//                         _sectionTitle("Choose Background"),
//                         const SizedBox(height: 12),
//                         SizedBox(
//                           height: 100,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: bgList.length,
//                             itemBuilder: (context, i) {
//                               return GestureDetector(
//                                 onTap: () {
//                                   selectedBgIndex.value = i;
//                                 },
//                                 child: Container(
//                                   margin: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color:
//                                           selectedBgIndex.value == i
//                                               ? Colors.deepPurple
//                                               : Colors.transparent,
//                                       width: 3,
//                                     ),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(12),
//                                     child: Image.asset(
//                                       bgList[i],
//                                       width: 100,
//                                       height: 100,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         _sectionTitle("FAQs"),
//                         const SizedBox(height: 12),
//                         _faqTile(
//                           "What is RETVRN?",
//                           "RETVRN is your reflective space to evolve emotionally and spiritually.",
//                         ),
//                         _faqTile(
//                           "How do I use Reflect & Evolve?",
//                           "Go to Reflect & Evolve section, respond to prompts daily.",
//                         ),
//                         _faqTile(
//                           "What does the Spiral Chart show?",
//                           "It tracks your evolution through Spiral Dynamics levels.",
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Sticky footer
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       color: Colors.black.withOpacity(0.3),
//                       child: FutureBuilder<String>(
//                         future: _getAppVersion(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Text(
//                               "Loading...",
//                               style: TextStyle(color: Colors.white70),
//                             );
//                           } else if (snapshot.hasError) {
//                             return const Text(
//                               "Version Unavailable",
//                               style: TextStyle(color: Colors.white70),
//                             );
//                           } else {
//                             return Text(
//                               "RETVRN v${snapshot.data}",
//                               style: const TextStyle(color: Colors.white70),
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: Colors.white,
//       ),
//     );
//   }

//   Widget _faqTile(String title, String answer) {
//     return ExpansionTile(
//       title: Text(title, style: const TextStyle(color: Colors.white)),
//       collapsedIconColor: Colors.white,
//       iconColor: Colors.deepPurpleAccent,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(answer, style: const TextStyle(color: Colors.white70)),
//         ),
//       ],
//     );
//   }

//   Future<String> _getAppVersion() async {
//     final info = await PackageInfo.fromPlatform();
//     return "${info.version}+${info.buildNumber}";
//   }
// }
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../main.dart'; // To access themeModeNotifier

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String version = '';

  List<Map<String, String>> faqs = [
    {
      'question': 'What is RETVRN?',
      'answer':
          'RETƲRN is your personal growth companion using AI journaling and guidance.',
    },
    {
      'question': 'How does journaling help?',
      'answer':
          'Journaling helps you reflect, understand emotions, and unlock growth patterns.',
    },
    {
      'question': 'What is Spiral Dynamics?',
      'answer':
          'It’s a model of human development through psychological stages.',
    },
    {
      'question': 'Is my data safe?',
      'answer':
          'Yes, your entries are stored securely and only visible to you.',
    },
    {
      'question': 'Can I record voice journals?',
      'answer':
          'Yes! You can speak your thoughts and we’ll transcribe and analyze them using AI.',
    },
    {
      'question': 'What are growth prompts?',
      'answer':
          'They’re reflective questions tailored to your current emotional stage to guide personal growth.',
    },
    {
      'question': 'How often should I journal?',
      'answer':
          'We recommend journaling daily or at least 3 times a week for best results.',
    },
    {
      'question': 'Who sees my data?',
      'answer': 'Only you. Your entries are encrypted and private by default.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("⚙️ Settings"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeModeNotifier.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeModeNotifier.value =
                  themeModeNotifier.value == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isDark
                        ? [Colors.black, Colors.grey[900]!]
                        : [Colors.white, Colors.lightBlue[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "❓ FAQs",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      itemCount: faqs.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        final faq = faqs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    faq['question']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isDark
                                              ? Colors.cyan[200]
                                              : Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    faq['answer']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          isDark
                                              ? Colors.grey[300]
                                              : Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Version at bottom
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        const Divider(thickness: 1),
                        Text(
                          "App Version: $version",
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
