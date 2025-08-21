import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  User? user;
  String? username;
  bool isLoading = true;
  bool isEditingUsername = false;

  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _usernameController = TextEditingController();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final uid = user?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      setState(() {
        username = data?['username'] ?? '';
        _usernameController.text = username!;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('My Account'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: textColor,
            ),
            onPressed: () {
              themeModeNotifier.value =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            (user?.displayName?.isNotEmpty ?? false)
                                ? user!.displayName![0].toUpperCase()
                                : "U",
                            style: const TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      _infoTile(
                        Icons.email,
                        "Email",
                        user?.email ?? '',
                        textColor,
                      ),
                      const SizedBox(height: 16),

                      _infoTile(
                        Icons.person,
                        "Name",
                        user?.displayName ?? 'No name set',
                        textColor,
                      ),
                      const SizedBox(height: 16),

                      _editableUsernameTile(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableUsernameTile() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.alternate_email, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child:
                isEditingUsername
                    ? TextField(
                      controller: _usernameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter new username',
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Username",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _usernameController.text,
                          style: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
          IconButton(
            icon: Icon(isEditingUsername ? Icons.check : Icons.edit),
            onPressed: () async {
              if (isEditingUsername) {
                final newUsername = _usernameController.text.trim();
                if (newUsername.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .set({'username': newUsername}, SetOptions(merge: true));

                  setState(() {
                    username = newUsername;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✅ Username updated!'),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                }
              }
              setState(() {
                isEditingUsername = !isEditingUsername;
              });
            },
          ),
        ],
      ),
    );
  }
}
