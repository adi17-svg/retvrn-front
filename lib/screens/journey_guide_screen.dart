import 'package:flutter/material.dart';

class JourneyGuideScreen extends StatelessWidget {
  const JourneyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontSize: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Journey Guide'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              icon: Icons.explore,
              title: "Overview",
              content:
                  "Welcome to your personal evolution space! This app helps you explore your inner world using the Spiral Dynamics model. "
                  "Whether you choose to speak or write, your input will be analyzed to guide you with meaningful reflections and growth prompts.",
              textStyle: textStyle,
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.edit_note,
              title: "1. Choose Input Mode",
              contentWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subtitleWithIcon("📝 Text Journaling"),
                  _bulletList([
                    "Tap the “Text Input” button.",
                    "Type freely about your current thoughts, feelings, or situation.",
                    "Submit to get a personalized analysis.",
                  ], textStyle),
                  const SizedBox(height: 12),
                  _subtitleWithIcon("🎙 Voice Journaling"),
                  _bulletList([
                    "Tap the “Voice Input” button.",
                    "Speak naturally about what’s on your mind.",
                    "Your voice will be transcribed and analyzed.",
                  ], textStyle),
                ],
              ),
              textStyle: textStyle,
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.insights,
              title: "2. Review Your Insights",
              content:
                  "Each submission is analyzed through Spiral Dynamics. You’ll see:\n"
                  "• The detected **stage of consciousness** (e.g., Blue, Orange, Green)\n"
                  "• A **deep reflective question** for your current state\n"
                  "• A **growth prompt** to help you evolve",
              textStyle: textStyle,
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.show_chart,
              title: "3. Track Your Evolution",
              content:
                  "View your evolution chart to track how your consciousness shifts over time. "
                  "This helps you reflect on your journey and patterns of growth.",
              textStyle: textStyle,
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.tips_and_updates,
              title: "📌 Tips for Meaningful Entries",
              content:
                  "• Be honest and unfiltered\n• Reflect on your current challenges, thoughts, or breakthroughs\n• Use this space to grow—not to impress",
              textStyle: textStyle,
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.favorite,
              title: "🙌 You're in Control",
              content:
                  "This is your safe space for inner growth.\nReturn anytime to reflect, realign, and evolve.",
              textStyle: textStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    String? content,
    Widget? contentWidget,
    TextStyle? textStyle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (content != null)
              Text(content, style: textStyle)
            else if (contentWidget != null)
              contentWidget,
          ],
        ),
      ),
    );
  }

  Widget _subtitleWithIcon(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _bulletList(List<String> items, TextStyle? style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text("• $item", style: style),
                ),
              )
              .toList(),
    );
  }
}
