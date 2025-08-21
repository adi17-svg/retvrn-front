import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  /// Create blank mergedMessages collection for a new user
  Future<void> _createBlankMergedMessages(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("mergedMessages")
          .doc("init") // creates first dummy doc
          .set({
            "createdAt": FieldValue.serverTimestamp(),
            "system": true,
            "message": "blank_init", // marker doc
          });
    } catch (e) {
      debugPrint("⚠ Error creating mergedMessages: $e");
    }
  }

  /// Save user data + FCM token to Firestore
  Future<void> _saveUserToFirestore(User user) async {
    try {
      // Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "email": user.email,
        "displayName": user.displayName,
        "photoURL": user.photoURL,
        "fcmToken": token, // 🔥 Save token here
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Create blank mergedMessages collection
      await _createBlankMergedMessages(user.uid);
    } catch (e) {
      debugPrint("⚠ Error saving user: $e");
    }
  }

  /// Register with Email & Password
  Future<void> _registerWithEmail() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError("Both fields are required to sign up.");
      return;
    }

    setState(() => _loading = true);
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCred.user;
      if (user != null) {
        await _saveUserToFirestore(user);
      }

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (_) {
      _showError("Registration failed. Please check your details.");
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Register with Google
  Future<void> _registerWithGoogle() async {
    setState(() => _loading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final auth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      UserCredential userCred = await _auth.signInWithCredential(credential);
      User? user = userCred.user;

      if (user != null) {
        await _saveUserToFirestore(user);
      }

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (_) {
      _showError("Google registration failed");
    } catch (_) {
      _showError("An unknown error occurred.");
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Error handler
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static const Color greenColor = Color(0xFF00C853);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconColor = textColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: iconColor,
                    ),
                    onPressed: () {
                      themeModeNotifier.value =
                          isDark ? ThemeMode.light : ThemeMode.dark;
                    },
                  ),
                ),
                const SizedBox(height: 40),
                Icon(Icons.bubble_chart_rounded, size: 80, color: iconColor),
                const SizedBox(height: 16),
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(_emailController, 'Email'),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, 'Password', obscure: true),
                const SizedBox(height: 24),
                _buildButton(
                  'Sign Up',
                  _registerWithEmail,
                  background: greenColor,
                ),
                const SizedBox(height: 16),
                _buildButton(
                  'Register with Google',
                  _registerWithGoogle,
                  icon: Icons.g_mobiledata,
                  background: Colors.grey.shade200,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: greenColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Input fields
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Buttons
  Widget _buildButton(
    String text,
    VoidCallback onPressed, {
    IconData? icon,
    required Color background,
  }) {
    final isLoading = _loading;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon:
            icon != null
                ? Icon(icon, color: Colors.black)
                : const SizedBox.shrink(),
        label:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
                : Text(text, style: const TextStyle(fontSize: 16)),
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
    );
  }
}
