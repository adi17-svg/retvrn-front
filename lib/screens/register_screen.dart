// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   Future<void> _registerWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Registration failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _registerWithGoogle() async {
//     setState(() => _loading = true);
//     try {
//       final googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) return;

//       final auth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: auth.accessToken,
//         idToken: auth.idToken,
//       );

//       await _auth.signInWithCredential(credential);
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Google registration failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   static const whiteShade = Colors.white;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ValueListenableBuilder<int>(
//         valueListenable: selectedBgIndex,
//         builder: (_, index, __) {
//           return Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.asset(bgList[index], fit: BoxFit.cover),
//               Container(color: Colors.black.withOpacity(0.5)),
//               Center(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: Card(
//                     color: Colors.white.withOpacity(0.15),
//                     elevation: 8,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           const Text(
//                             'Create Account',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: whiteShade,
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 32),
//                           _buildTextField(_emailController, 'Email'),
//                           const SizedBox(height: 16),
//                           _buildTextField(
//                             _passwordController,
//                             'Password',
//                             obscure: true,
//                           ),
//                           const SizedBox(height: 24),
//                           _buildButton('Register', _registerWithEmail),
//                           const SizedBox(height: 12),
//                           _buildButton(
//                             'Register with Google',
//                             _registerWithGoogle,
//                             icon: Icons.login,
//                           ),
//                           const SizedBox(height: 24),
//                           TextButton(
//                             onPressed:
//                                 () => Navigator.pushReplacementNamed(
//                                   context,
//                                   '/login',
//                                 ),
//                             child: const Text(
//                               'Already have an account? Login',
//                               style: TextStyle(color: whiteShade),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               _buildTopLeftBackgroundSelector(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label, {
//     bool obscure = false,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       style: const TextStyle(color: whiteShade),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: whiteShade),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.1),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }

//   Widget _buildButton(String text, VoidCallback onPressed, {IconData? icon}) {
//     return ElevatedButton.icon(
//       onPressed: _loading ? null : onPressed,
//       icon:
//           icon != null
//               ? Icon(icon, color: Colors.black)
//               : const SizedBox.shrink(),
//       label:
//           _loading
//               ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.black,
//                   strokeWidth: 2,
//                 ),
//               )
//               : Text(text),
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.black,
//         backgroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   Widget _buildTopLeftBackgroundSelector() {
//     return Positioned(
//       top: 40,
//       left: 16,
//       child: PopupMenuButton<int>(
//         onSelected: (int index) {
//           selectedBgIndex.value = index;
//         },
//         icon: const Icon(Icons.palette, color: Colors.white),
//         color: Colors.black.withOpacity(0.7),
//         itemBuilder:
//             (context) => List.generate(bgList.length, (i) {
//               return PopupMenuItem(
//                 value: i,
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundImage: AssetImage(bgList[i]),
//                       radius: 14,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Background ${i + 1}',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   Future<void> _registerWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Registration failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _registerWithGoogle() async {
//     setState(() => _loading = true);
//     try {
//       print('🟡 Starting Google Sign-In...');
//       final googleUser =
//           await GoogleSignIn(
//             clientId:
//                 '1002466229581-ki596si2ehvk70imuunq1sijhuueune0.apps.googleusercontent.com', // Replace with your correct Web Client ID
//           ).signIn();

//       if (googleUser == null) {
//         print('🔴 User cancelled Google sign-in.');
//         _showError('Google sign-in was cancelled');
//         return;
//       }

//       print('🟢 Google user signed in: ${googleUser.email}');

//       final auth = await googleUser.authentication;
//       print('✅ Got tokens');
//       print('accessToken: ${auth.accessToken}');
//       print('idToken: ${auth.idToken}');

//       final credential = GoogleAuthProvider.credential(
//         accessToken: auth.accessToken,
//         idToken: auth.idToken,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);
//       print('✅ Firebase sign-in successful: ${userCredential.user?.email}');

//       Navigator.pushReplacementNamed(context, '/home');
//     } catch (e) {
//       print('🔴 Google Sign-In failed: $e');
//       _showError('Google Sign-In failed. Check logs for details.');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   static const whiteShade = Colors.white;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ValueListenableBuilder<int>(
//         valueListenable: selectedBgIndex,
//         builder: (_, index, __) {
//           return Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.asset(bgList[index], fit: BoxFit.cover),
//               Container(color: Colors.black.withOpacity(0.5)),
//               Center(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: Card(
//                     color: Colors.white.withOpacity(0.15),
//                     elevation: 8,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           const Text(
//                             'Create Account',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: whiteShade,
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 32),
//                           _buildTextField(_emailController, 'Email'),
//                           const SizedBox(height: 16),
//                           _buildTextField(
//                             _passwordController,
//                             'Password',
//                             obscure: true,
//                           ),
//                           const SizedBox(height: 24),
//                           _buildButton('Register', _registerWithEmail),
//                           const SizedBox(height: 12),
//                           _buildButton(
//                             'Register with Google',
//                             _registerWithGoogle,
//                             icon: Icons.login,
//                           ),
//                           const SizedBox(height: 24),
//                           TextButton(
//                             onPressed:
//                                 () => Navigator.pushReplacementNamed(
//                                   context,
//                                   '/login',
//                                 ),
//                             child: const Text(
//                               'Already have an account? Login',
//                               style: TextStyle(color: whiteShade),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               _buildTopLeftBackgroundSelector(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label, {
//     bool obscure = false,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       style: const TextStyle(color: whiteShade),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: whiteShade),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.1),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }

//   Widget _buildButton(String text, VoidCallback onPressed, {IconData? icon}) {
//     return ElevatedButton.icon(
//       onPressed: _loading ? null : onPressed,
//       icon:
//           icon != null
//               ? Icon(icon, color: Colors.black)
//               : const SizedBox.shrink(),
//       label:
//           _loading
//               ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.black,
//                   strokeWidth: 2,
//                 ),
//               )
//               : Text(text),
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.black,
//         backgroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   Widget _buildTopLeftBackgroundSelector() {
//     return Positioned(
//       top: 40,
//       left: 16,
//       child: PopupMenuButton<int>(
//         onSelected: (int index) {
//           selectedBgIndex.value = index;
//         },
//         icon: const Icon(Icons.palette, color: Colors.white),
//         color: Colors.black.withOpacity(0.7),
//         itemBuilder:
//             (context) => List.generate(bgList.length, (i) {
//               return PopupMenuItem(
//                 value: i,
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundImage: AssetImage(bgList[i]),
//                       radius: 14,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Background ${i + 1}',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   Future<void> _registerWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Registration failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _registerWithGoogle() async {
//     setState(() => _loading = true);
//     try {
//       print('🟡 Starting Google Sign-In...');
//       final googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) {
//         print('⚠️ Google sign-in was cancelled by user.');
//         return;
//       }

//       final auth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: auth.accessToken,
//         idToken: auth.idToken,
//       );

//       print('✅ Got Google credentials, signing in to Firebase...');
//       final userCredential = await _auth.signInWithCredential(credential);
//       print('🎉 Firebase sign-in successful: ${userCredential.user?.email}');
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       print('❌ FirebaseAuthException: ${e.message}');
//       _showError(e.message ?? 'Google registration failed');
//     } catch (e) {
//       print('❌ Unknown error: $e');
//       _showError('An unknown error occurred.');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   static const whiteShade = Colors.white;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ValueListenableBuilder<int>(
//         valueListenable: selectedBgIndex,
//         builder: (_, index, __) {
//           return Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.asset(bgList[index], fit: BoxFit.cover),
//               Container(color: Colors.black.withOpacity(0.5)),
//               Center(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: Card(
//                     color: Colors.white.withOpacity(0.15),
//                     elevation: 8,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           const Text(
//                             'Create Account',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: whiteShade,
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 32),
//                           _buildTextField(_emailController, 'Email'),
//                           const SizedBox(height: 16),
//                           _buildTextField(
//                             _passwordController,
//                             'Password',
//                             obscure: true,
//                           ),
//                           const SizedBox(height: 24),
//                           _buildButton('Register', _registerWithEmail),
//                           const SizedBox(height: 12),
//                           _buildButton(
//                             'Register with Google',
//                             _registerWithGoogle,
//                             icon: Icons.login,
//                           ),
//                           const SizedBox(height: 24),
//                           TextButton(
//                             onPressed:
//                                 () => Navigator.pushReplacementNamed(
//                                   context,
//                                   '/login',
//                                 ),
//                             child: const Text(
//                               'Already have an account? Login',
//                               style: TextStyle(color: whiteShade),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               _buildTopLeftBackgroundSelector(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label, {
//     bool obscure = false,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       style: const TextStyle(color: whiteShade),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: whiteShade),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.1),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }

//   Widget _buildButton(String text, VoidCallback onPressed, {IconData? icon}) {
//     return ElevatedButton.icon(
//       onPressed: _loading ? null : onPressed,
//       icon:
//           icon != null
//               ? Icon(icon, color: Colors.black)
//               : const SizedBox.shrink(),
//       label:
//           _loading
//               ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.black,
//                   strokeWidth: 2,
//                 ),
//               )
//               : Text(text),
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.black,
//         backgroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   Widget _buildTopLeftBackgroundSelector() {
//     return Positioned(
//       top: 40,
//       left: 16,
//       child: PopupMenuButton<int>(
//         onSelected: (int index) {
//           selectedBgIndex.value = index;
//         },
//         icon: const Icon(Icons.palette, color: Colors.white),
//         color: Colors.black.withOpacity(0.7),
//         itemBuilder:
//             (context) => List.generate(bgList.length, (i) {
//               return PopupMenuItem(
//                 value: i,
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundImage: AssetImage(bgList[i]),
//                       radius: 14,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Background ${i + 1}',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   Future<void> _registerWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Registration failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _registerWithGoogle() async {
//     setState(() => _loading = true);
//     try {
//       final googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) return;

//       final auth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: auth.accessToken,
//         idToken: auth.idToken,
//       );
//       await _auth.signInWithCredential(credential);
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Google registration failed');
//     } catch (e) {
//       _showError('An unknown error occurred.');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   static const Color greenColor = Color(0xFF00C853); // Green
//   static const Color orangeColor = Color(0xFFFF9100); // Orange

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final iconColor = textColor;
//     final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Theme toggle button (top right)
//                     Align(
//                       alignment: Alignment.topRight,
//                       child: IconButton(
//                         icon: Icon(
//                           isDark ? Icons.light_mode : Icons.dark_mode,
//                           color: iconColor,
//                         ),
//                         onPressed: () {
//                           themeModeNotifier.value =
//                               isDark ? ThemeMode.light : ThemeMode.dark;
//                         },
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     // App Icon
//                     Icon(
//                       Icons.bubble_chart_rounded,
//                       size: 80,
//                       color: iconColor,
//                     ),

//                     const SizedBox(height: 16),

//                     Text(
//                       'Create Account',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: textColor,
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     _buildTextField(_emailController, 'Email'),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       _passwordController,
//                       'Password',
//                       obscure: true,
//                     ),
//                     const SizedBox(height: 24),

//                     // Green Register button
//                     _buildButton(
//                       'Sign Up',
//                       _registerWithEmail,
//                       background: greenColor,
//                     ),

//                     const SizedBox(height: 16),

//                     // Google Sign-In
//                     _buildButton(
//                       'Register with Google',
//                       _registerWithGoogle,
//                       icon: Icons.g_mobiledata,
//                       background: Colors.grey.shade200,
//                     ),

//                     const SizedBox(height: 16),

//                     // Already have account
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Already have an account? ",
//                           style: TextStyle(color: Colors.grey[700]),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.pushReplacementNamed(context, '/login');
//                           },
//                           child: Text(
//                             'Login',
//                             style: TextStyle(
//                               color: orangeColor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 32),
//                   ],
//                 ),
//               ),
//             ),

//             // Background selector (top-left)
//             _buildTopLeftBackgroundSelector(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label, {
//     bool obscure = false,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
//         filled: true,
//         fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
//         contentPadding: const EdgeInsets.symmetric(
//           vertical: 18,
//           horizontal: 20,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(24),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }

//   Widget _buildButton(
//     String text,
//     VoidCallback onPressed, {
//     IconData? icon,
//     required Color background,
//   }) {
//     final isLoading = _loading;
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton.icon(
//         icon:
//             icon != null
//                 ? Icon(icon, color: Colors.black)
//                 : const SizedBox.shrink(),
//         label:
//             isLoading
//                 ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     color: Colors.black,
//                     strokeWidth: 2,
//                   ),
//                 )
//                 : Text(text, style: const TextStyle(fontSize: 16)),
//         onPressed: isLoading ? null : onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: background,
//           foregroundColor: Colors.black,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(32),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTopLeftBackgroundSelector() {
//     return Positioned(
//       top: 40,
//       left: 16,
//       child: PopupMenuButton<int>(
//         onSelected: (int index) {
//           selectedBgIndex.value = index;
//         },
//         icon: const Icon(Icons.palette),
//         itemBuilder:
//             (context) => List.generate(bgList.length, (i) {
//               return PopupMenuItem(
//                 value: i,
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundImage: AssetImage(bgList[i]),
//                       radius: 14,
//                     ),
//                     const SizedBox(width: 8),
//                     Text('Background ${i + 1}'),
//                   ],
//                 ),
//               );
//             }),
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../main.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   Future<void> _registerWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Registration failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _registerWithGoogle() async {
//     setState(() => _loading = true);
//     try {
//       final googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) return;

//       final auth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: auth.accessToken,
//         idToken: auth.idToken,
//       );
//       await _auth.signInWithCredential(credential);
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Google registration failed');
//     } catch (e) {
//       _showError('An unknown error occurred.');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   static const Color greenColor = Color(0xFF00C853); // Unified Green

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final iconColor = textColor;
//     final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Theme toggle button (top right)
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: IconButton(
//                     icon: Icon(
//                       isDark ? Icons.light_mode : Icons.dark_mode,
//                       color: iconColor,
//                     ),
//                     onPressed: () {
//                       themeModeNotifier.value =
//                           isDark ? ThemeMode.light : ThemeMode.dark;
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // App Icon
//                 Icon(Icons.bubble_chart_rounded, size: 80, color: iconColor),

//                 const SizedBox(height: 16),

//                 Text(
//                   'Create Account',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: textColor,
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 _buildTextField(_emailController, 'Email'),
//                 const SizedBox(height: 16),
//                 _buildTextField(_passwordController, 'Password', obscure: true),
//                 const SizedBox(height: 24),

//                 // Green Register button
//                 _buildButton(
//                   'Sign Up',
//                   _registerWithEmail,
//                   background: greenColor,
//                 ),

//                 const SizedBox(height: 16),

//                 // Google Sign-In
//                 _buildButton(
//                   'Register with Google',
//                   _registerWithGoogle,
//                   icon: Icons.g_mobiledata,
//                   background: Colors.grey.shade200,
//                 ),

//                 const SizedBox(height: 16),

//                 // Already have account
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Already have an account? ",
//                       style: TextStyle(color: Colors.grey[700]),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushReplacementNamed(context, '/login');
//                       },
//                       child: Text(
//                         'Login',
//                         style: TextStyle(
//                           color: greenColor, // Updated to match Sign Up button
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label, {
//     bool obscure = false,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
//         filled: true,
//         fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
//         contentPadding: const EdgeInsets.symmetric(
//           vertical: 18,
//           horizontal: 20,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(24),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }

//   Widget _buildButton(
//     String text,
//     VoidCallback onPressed, {
//     IconData? icon,
//     required Color background,
//   }) {
//     final isLoading = _loading;
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton.icon(
//         icon:
//             icon != null
//                 ? Icon(icon, color: Colors.black)
//                 : const SizedBox.shrink(),
//         label:
//             isLoading
//                 ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     color: Colors.black,
//                     strokeWidth: 2,
//                   ),
//                 )
//                 : Text(text, style: const TextStyle(fontSize: 16)),
//         onPressed: isLoading ? null : onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: background,
//           foregroundColor: Colors.black,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(32),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  Future<void> _registerWithEmail() async {
    // Check for empty fields before calling Firebase
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError("Both fields are required to sign up.");
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (_) {
      _showError("Registration failed. Please check your details.");
    } finally {
      setState(() => _loading = false);
    }
  }

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
      await _auth.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (_) {
      _showError("Google registration failed");
    } catch (_) {
      _showError("An unknown error occurred.");
    } finally {
      setState(() => _loading = false);
    }
  }

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
