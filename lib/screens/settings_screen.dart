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
