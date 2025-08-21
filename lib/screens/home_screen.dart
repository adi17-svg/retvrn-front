import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  String? username;
  String? _currentStage;
  bool _isLoadingStage = true;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    fetchUsername();
    _fetchCurrentStage();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskForName());
  }

  Future<void> fetchUsername() async {
    final uid = user?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        username = doc.data()?['username'];
      });
    }
  }

  Future<void> _fetchCurrentStage() async {
    setState(() => _isLoadingStage = true);
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('mergedMessages')
              .orderBy('timestamp', descending: true)
              .limit(20)
              .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['type'] == 'spiral' &&
            data['stage'] != null &&
            data['stage'].toString().trim().isNotEmpty) {
          setState(() {
            _currentStage = data['stage'];
          });
          break;
        }
      }
    } catch (e) {
      print('Error while fetching current stage: $e');
    } finally {
      setState(() => _isLoadingStage = false);
    }
  }

  Future<void> _maybeAskForName() async {
    if (user != null &&
        (user!.displayName == null || user!.displayName!.isEmpty)) {
      final name = await _promptForName();
      if (name != null && name.trim().isNotEmpty) {
        await user!.updateDisplayName(name.trim());
        await user!.reload();
        user = FirebaseAuth.instance.currentUser;
        setState(() {});
      }
    }
  }

  Future<String?> _promptForName() async {
    String enteredName = '';
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Hi there! 👋"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("What should we call you?"),
                const SizedBox(height: 12),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Your name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                  ),
                  onChanged: (value) => enteredName = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(enteredName),
                child: const Text("Continue"),
              ),
            ],
          ),
    );
  }

  Future<void> _logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseMessaging.instance.unsubscribeFromTopic('user_${user.uid}');
    }
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildStageIndicator() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('mergedMessages')
              .orderBy('timestamp', descending: true)
              .limit(20)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // 👇 Styled welcome container instead of plain text
          return _buildWelcomeContainer();
        }

        String? stage;
        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['type'] == 'spiral' &&
              data['stage'] != null &&
              data['stage'].toString().trim().isNotEmpty) {
            stage = data['stage'];
            break;
          }
        }

        if (stage == null) {
          return _buildWelcomeContainer();
        }

        Color bgColor;
        switch (stage.toLowerCase()) {
          case 'red':
            bgColor = Colors.redAccent;
            break;
          case 'blue':
            bgColor = Colors.blueAccent;
            break;
          case 'green':
            bgColor = Colors.green;
            break;
          case 'orange':
            bgColor = Colors.deepOrange;
            break;
          case 'yellow':
            bgColor = Colors.amber;
            break;
          case 'turquoise':
            bgColor = Colors.teal;
            break;
          default:
            bgColor = Colors.grey;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              children: [
                const Text(
                  "CURRENT STAGE",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stage.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 👇 New helper widget for styled welcome message
  Widget _buildWelcomeContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "Welcome aboard! 🌱 Start your journey—head to Reflect and begin evolving.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final appBarBg =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    final appBarFg =
        Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onPrimary;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final displayName = username ?? user?.displayName ?? "User";
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'RETᐯRN',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 2,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: appBarFg),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: appBarFg),
            onPressed: _fetchCurrentStage,
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: appBarFg,
            ),
            onPressed: () {
              themeModeNotifier.value =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("My Account"),
                    onTap: () async {
                      await Navigator.pushNamed(context, '/myaccount');
                      user = FirebaseAuth.instance.currentUser;
                      await fetchUsername();
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Help"),
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Logout"),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Welcome, $displayName!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    _buildStageIndicator(),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  padding: const EdgeInsets.only(top: 30),
                  children: [
                    _buildTile(
                      Icons.book,
                      "Spiral Guide",
                      Colors.green,
                      '/guide',
                    ),
                    _buildTile(
                      Icons.explore,
                      "Journey Guide",
                      Colors.orange,
                      '/journeyguide',
                    ),
                    _buildTile(
                      Icons.chat,
                      "Reflect & Evolve",
                      Colors.indigo,
                      '/chat',
                    ),
                    _buildTile(
                      Icons.show_chart,
                      "Your Growth",
                      Colors.purple,
                      '/graph',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    Color color,
    String routeName,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
