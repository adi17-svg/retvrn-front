//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../data/bg_data.dart';
// import '../main.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _loading = false;
//
//   Future<void> _signInWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       final userCredential = await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       if (userCredential.user != null) {
//         Navigator.pushReplacementNamed(context, '/home');
//       }
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Login failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   Future<void> _signInWithGoogle() async {
//     setState(() => _loading = true);
//     try {
//       final googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) return;
//       final googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       final userCredential = await _auth.signInWithCredential(credential);
//       if (userCredential.user != null) {
//         Navigator.pushReplacementNamed(context, '/home');
//       }
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Google sign-in failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ValueListenableBuilder(
//         valueListenable: selectedBgIndex,
//         builder: (context, index, _) {
//           return Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage(bgList[index]),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 28),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Welcome Back!',
//                       style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 30),
//                     TextField(
//                       controller: _emailController,
//                       style: const TextStyle(color: Colors.white),
//                       decoration: const InputDecoration(labelText: 'Email'),
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       style: const TextStyle(color: Colors.white),
//                       decoration: const InputDecoration(labelText: 'Password'),
//                     ),
//                     const SizedBox(height: 28),
//                     ElevatedButton(
//                       onPressed: _loading ? null : _signInWithEmail,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2142F1),
//                         minimumSize: const Size(double.infinity, 50),
//                       ),
//                       child: _loading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text('Login'),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.login, color: Colors.white),
//                       label: const Text('Sign in with Google'),
//                       onPressed: _loading ? null : _signInWithGoogle,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF4267B2),
//                         minimumSize: const Size(double.infinity, 50),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextButton(
//                       onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
//                       child: const Text(
//                         'Don\'t have an account? Sign up',
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: SizedBox(
//         height: 80,
//         child: Row(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: bgList.length,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () => selectedBgIndex.value = index,
//                     child: CircleAvatar(
//                       backgroundImage: AssetImage(bgList[index]),
//                       radius: 30,
//                       backgroundColor: selectedBgIndex.value == index ? Colors.white : Colors.transparent,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../data/bg_data.dart';
// import '../main.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;
//
//   Future<void> _signInWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Login failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   Future<void> _signInWithGoogle() async {
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
//       _showError(e.message ?? 'Google sign-in failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
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
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           const Text(
//                             'Welcome Back!',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 32),
//                           _buildTextField(_emailController, 'Email'),
//                           const SizedBox(height: 16),
//                           _buildTextField(_passwordController, 'Password', obscure: true),
//                           const SizedBox(height: 24),
//                           _buildButton('Login', _signInWithEmail),
//                           const SizedBox(height: 12),
//                           _buildButton('Sign in with Google', _signInWithGoogle, icon: Icons.login),
//                           const SizedBox(height: 24),
//                           TextButton(
//                             onPressed: () =>
//                                 Navigator.pushReplacementNamed(context, '/register'),
//                             child: const Text(
//                               'Don\'t have an account? Sign up',
//                               style: TextStyle(color: Colors.white),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               _buildBackgroundSelector(),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label,
//       {bool obscure = false}) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.white),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.1),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildButton(String text, VoidCallback onPressed, {IconData? icon}) {
//     return ElevatedButton.icon(
//       onPressed: _loading ? null : onPressed,
//       icon: icon != null ? Icon(icon, color: Colors.black) : const SizedBox.shrink(),
//       label: _loading
//           ? const SizedBox(
//         width: 20,
//         height: 20,
//         child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
//       )
//           : Text(text),
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.black,
//         backgroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   Widget _buildBackgroundSelector() {
//     return Positioned(
//       bottom: 16,
//       left: 0,
//       right: 0,
//       height: 60,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: bgList.length,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemBuilder: (_, i) {
//           final selected = selectedBgIndex.value == i;
//           return GestureDetector(
//             onTap: () => selectedBgIndex.value = i,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 border: selected
//                     ? Border.all(color: Colors.white, width: 3)
//                     : null,
//                 shape: BoxShape.circle,
//               ),
//               child: CircleAvatar(
//                 radius: 28,
//                 backgroundImage: AssetImage(bgList[i]),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../data/bg_data.dart';
// import '../main.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;
//
//   Future<void> _signInWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Login failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   Future<void> _signInWithGoogle() async {
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
//       _showError(e.message ?? 'Google sign-in failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
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
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Welcome Back!',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Card(
//                         color: Colors.white,
//                         elevation: 8,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16)),
//                         child: Padding(
//                           padding: const EdgeInsets.all(24),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               _buildTextField(_emailController, 'Email'),
//                               const SizedBox(height: 16),
//                               _buildTextField(_passwordController, 'Password', obscure: true),
//                               const SizedBox(height: 24),
//                               _buildButton('Login', _signInWithEmail),
//                               const SizedBox(height: 12),
//                               _buildButton('Sign in with Google', _signInWithGoogle, icon: Icons.login),
//                               const SizedBox(height: 24),
//                               TextButton(
//                                 onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
//                                 child: const Text(
//                                   'Don\'t have an account? Sign up',
//                                   style: TextStyle(color: Colors.black),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               _buildBackgroundSelector(),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label,
//       {bool obscure = false}) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       style: const TextStyle(color: Colors.black),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.9),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildButton(String text, VoidCallback onPressed, {IconData? icon}) {
//     return ElevatedButton.icon(
//       onPressed: _loading ? null : onPressed,
//       icon: icon != null ? Icon(icon, color: Colors.black) : const SizedBox.shrink(),
//       label: _loading
//           ? const SizedBox(
//         width: 20,
//         height: 20,
//         child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
//       )
//           : Text(text),
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.black,
//         backgroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   Widget _buildBackgroundSelector() {
//     return Positioned(
//       bottom: 16,
//       left: 0,
//       right: 0,
//       height: 60,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: bgList.length,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemBuilder: (_, i) {
//           final selected = selectedBgIndex.value == i;
//           return GestureDetector(
//             onTap: () => selectedBgIndex.value = i,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 border: selected ? Border.all(color: Colors.white, width: 3) : null,
//                 shape: BoxShape.circle,
//               ),
//               child: CircleAvatar(
//                 radius: 28,
//                 backgroundImage: AssetImage(bgList[i]),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../data/bg_data.dart';
// import '../main.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;
//
//   Future<void> _signInWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Login failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   Future<void> _signInWithGoogle() async {
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
//       _showError(e.message ?? 'Google sign-in failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   static const Color whiteShade = Colors.white;
//
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
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           const Text(
//                             'Welcome Back!',
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
//                           _buildTextField(_passwordController, 'Password', obscure: true),
//                           const SizedBox(height: 24),
//                           _buildButton('Login', _signInWithEmail),
//                           const SizedBox(height: 12),
//                           _buildButton('Sign in with Google', _signInWithGoogle, icon: Icons.login),
//                           const SizedBox(height: 24),
//                           TextButton(
//                             onPressed: () =>
//                                 Navigator.pushReplacementNamed(context, '/register'),
//                             child: const Text(
//                               'Don\'t have an account? Sign up',
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
//               _buildBackgroundSelector(),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label,
//       {bool obscure = false}) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       style: const TextStyle(color: whiteShade), // White text color for input
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: whiteShade), // White label color
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.1),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildButton(String text, VoidCallback onPressed, {IconData? icon}) {
//     return ElevatedButton.icon(
//       onPressed: _loading ? null : onPressed,
//       icon: icon != null ? Icon(icon, color: Colors.black) : const SizedBox.shrink(),
//       label: _loading
//           ? const SizedBox(
//         width: 20,
//         height: 20,
//         child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
//       )
//           : Text(text),
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.black,
//         backgroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   Widget _buildBackgroundSelector() {
//     return Positioned(
//       bottom: 16,
//       left: 0,
//       right: 0,
//       height: 60,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: bgList.length,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemBuilder: (_, i) {
//           final selected = selectedBgIndex.value == i;
//           return GestureDetector(
//             onTap: () => selectedBgIndex.value = i,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 border: selected
//                     ? Border.all(color: Colors.white, width: 3)
//                     : null,
//                 shape: BoxShape.circle,
//               ),
//               child: CircleAvatar(
//                 radius: 28,
//                 backgroundImage: AssetImage(bgList[i]),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// login_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../data/bg_data.dart';
// import '../main.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;
//
//   Future<void> _signInWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Login failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   Future<void> _signInWithGoogle() async {
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
//       _showError(e.message ?? 'Google sign-in failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   static const Color whiteShade = Colors.white;
//
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
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           const Text(
//                             'Welcome Back!',
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
//                           _buildTextField(_passwordController, 'Password', obscure: true),
//                           const SizedBox(height: 24),
//                           _buildButton('Login', _signInWithEmail),
//                           const SizedBox(height: 12),
//                           _buildButton('Sign in with Google', _signInWithGoogle, icon: Icons.login),
//                           const SizedBox(height: 24),
//                           TextButton(
//                             onPressed: () =>
//                                 Navigator.pushReplacementNamed(context, '/register'),
//                             child: const Text(
//                               'Don\'t have an account? Sign up',
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
//
//   Widget _buildTextField(TextEditingController controller, String label,
//       {bool obscure = false}) {
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
//
//   Widget _buildButton(String text, VoidCallback onPressed, {IconData? icon}) {
//     return ElevatedButton.icon(
//       onPressed: _loading ? null : onPressed,
//       icon: icon != null ? Icon(icon, color: Colors.black) : const SizedBox.shrink(),
//       label: _loading
//           ? const SizedBox(
//         width: 20,
//         height: 20,
//         child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
//       )
//           : Text(text),
//       style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.black,
//         backgroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 50),
//         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   Widget _buildTopLeftBackgroundSelector() {
//     return Positioned(
//       top: 40,
//       left: 16,
//       child: PopupMenuButton<int>(
//         onSelected: (int index) {
//           selectedBgIndex.value = index;
//         },
//         icon: const Icon(Icons.palette, color: Colors.white),
//         color: Colors.white,
//         itemBuilder: (context) => List.generate(bgList.length, (i) {
//           return PopupMenuItem(
//             value: i,
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   backgroundImage: AssetImage(bgList[i]),
//                   radius: 14,
//                 ),
//                 const SizedBox(width: 8),
//                 Text('Background ${i + 1}'),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   Future<void> _signInWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Login failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _signInWithGoogle() async {
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
//       _showError(e.message ?? 'Google sign-in failed');
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

//   static const Color whiteShade = Colors.white;

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
//                             'Welcome Back!',
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
//                           _buildButton('Login', _signInWithEmail),
//                           const SizedBox(height: 12),
//                           _buildButton(
//                             'Sign in with Google',
//                             _signInWithGoogle,
//                             icon: Icons.login,
//                           ),
//                           const SizedBox(height: 24),
//                           TextButton(
//                             onPressed:
//                                 () => Navigator.pushReplacementNamed(
//                                   context,
//                                   '/register',
//                                 ),
//                             child: const Text(
//                               'Don\'t have an account? Sign up',
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

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   Future<void> _signInWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Login failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _signInWithGoogle() async {
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
//       _showError(e.message ?? 'Google sign-in failed');
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

//   static const Color orangeColor = Color(0xFFFF9100);

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
//                       'Sign In',
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

//                     // Orange Sign In button
//                     _buildButton(
//                       'Sign in',
//                       _signInWithEmail,
//                       background: orangeColor,
//                     ),

//                     const SizedBox(height: 16),

//                     // Google Sign-In
//                     _buildButton(
//                       'Sign in with Google',
//                       _signInWithGoogle,
//                       icon: Icons.g_mobiledata,
//                       background: Colors.grey.shade200,
//                     ),

//                     const SizedBox(height: 16),

//                     // Sign Up
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Don't have an account? ",
//                           style: TextStyle(color: Colors.grey[700]),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.pushReplacementNamed(
//                               context,
//                               '/register',
//                             );
//                           },
//                           child: Text(
//                             'Sign Up',
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
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../main.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   Future<void> _signInWithEmail() async {
//     setState(() => _loading = true);
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.pushReplacementNamed(context, '/home');
//     } on FirebaseAuthException catch (e) {
//       _showError(e.message ?? 'Login failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _signInWithGoogle() async {
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
//       _showError(e.message ?? 'Google sign-in failed');
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

//   static const Color orangeColor = Color(0xFFFF9100);

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
//                   'Sign In',
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

//                 // Orange Sign In button
//                 _buildButton(
//                   'Sign in',
//                   _signInWithEmail,
//                   background: orangeColor,
//                 ),

//                 const SizedBox(height: 16),

//                 // Google Sign-In
//                 _buildButton(
//                   'Sign in with Google',
//                   _signInWithGoogle,
//                   icon: Icons.g_mobiledata,
//                   background: Colors.grey.shade200,
//                 ),

//                 const SizedBox(height: 16),

//                 // Sign Up
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Don't have an account? ",
//                       style: TextStyle(color: Colors.grey[700]),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushReplacementNamed(context, '/register');
//                       },
//                       child: Text(
//                         'Sign Up',
//                         style: TextStyle(
//                           color: orangeColor,
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _signInWithEmail() async {
    // Check for empty fields before calling Firebase
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError("Both fields are required to sign in.");
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      // Map all auth errors to a safe generic message
      _showError("Incorrect email/password combination.");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
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
      _showError("Google sign-in failed");
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

  static const Color orangeColor = Color(0xFFFF9100);

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
                  'Sign In',
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
                  'Sign in',
                  _signInWithEmail,
                  background: orangeColor,
                ),
                const SizedBox(height: 16),
                _buildButton(
                  'Sign in with Google',
                  _signInWithGoogle,
                  icon: Icons.g_mobiledata,
                  background: Colors.grey.shade200,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: orangeColor,
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
