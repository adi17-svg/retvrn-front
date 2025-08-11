// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   User? user;
//   String? username;

//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser;
//     fetchUsername();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskForName());
//   }

//   Future<void> fetchUsername() async {
//     final uid = user?.uid;
//     if (uid != null) {
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       final data = doc.data();
//       setState(() {
//         username = data?['username'];
//       });
//     }
//   }

//   Future<void> _maybeAskForName() async {
//     if (user != null &&
//         (user!.displayName == null || user!.displayName!.isEmpty)) {
//       final name = await _promptForName();
//       if (name != null && name.trim().isNotEmpty) {
//         await user!.updateDisplayName(name.trim());
//         await user!.reload();
//         user = FirebaseAuth.instance.currentUser;
//         setState(() {});
//       }
//     }
//   }

//   Future<String?> _promptForName() async {
//     String enteredName = '';
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Hi there! 👋"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("What should we call you?"),
//                 const SizedBox(height: 12),
//                 TextField(
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     hintText: "Your name",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                   ),
//                   onChanged: (value) => enteredName = value,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(enteredName),
//                 child: const Text("Continue"),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     await GoogleSignIn().signOut();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final displayName = username ?? user?.displayName ?? "User";
//     final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

//     return Scaffold(
//       drawer: Drawer(
//         child: Stack(
//           children: [
//             ValueListenableBuilder(
//               valueListenable: selectedBgIndex,
//               builder:
//                   (_, index, __) => Image.asset(
//                     bgList[index],
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: double.infinity,
//                   ),
//             ),
//             Container(color: Colors.black.withOpacity(0.5)),
//             SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 30),
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.white.withOpacity(0.8),
//                         child: Text(
//                           initial,
//                           style: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         displayName,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       GlassCard(
//                         icon: Icons.person,
//                         color: Colors.deepPurple,
//                         title: "My Account",
//                         onTap: () async {
//                           await Navigator.pushNamed(context, '/myaccount');
//                           user = FirebaseAuth.instance.currentUser;
//                           await fetchUsername(); // Reload display name + username
//                           setState(() {});
//                         },
//                       ),
//                       GlassCard(
//                         icon: Icons.settings,
//                         color: Colors.blue,
//                         title: "Appearance & Help",
//                         onTap: () => Navigator.pushNamed(context, '/settings'),
//                       ),
//                       GlassCard(
//                         icon: Icons.logout,
//                         color: Colors.red,
//                         title: "Logout",
//                         onTap: _logout,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: selectedBgIndex,
//         builder: (_, index, __) {
//           return Stack(
//             children: [
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 500),
//                 child: Image.asset(
//                   bgList[index],
//                   key: ValueKey(index),
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//               ),
//               Positioned.fill(
//                 child: Container(color: Colors.black.withOpacity(0.4)),
//               ),
//               SafeArea(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       child: Row(
//                         children: [
//                           Builder(
//                             builder:
//                                 (context) => IconButton(
//                                   icon: const Icon(
//                                     Icons.menu,
//                                     color: Colors.white,
//                                   ),
//                                   onPressed:
//                                       () => Scaffold.of(context).openDrawer(),
//                                 ),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                             icon: const Icon(Icons.logout, color: Colors.white),
//                             onPressed: _logout,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Welcome, $displayName!',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     Expanded(
//                       child: ListView(
//                         padding: const EdgeInsets.symmetric(horizontal: 24),
//                         children: [
//                           GlassCard(
//                             icon: Icons.book,
//                             color: Colors.green,
//                             title: "User Guide",
//                             onTap: () => Navigator.pushNamed(context, '/guide'),
//                           ),
//                           GlassCard(
//                             icon: Icons.chat,
//                             color: Colors.indigo,
//                             title: "Reflect & Evolve",
//                             onTap: () => Navigator.pushNamed(context, '/chat'),
//                           ),
//                           GlassCard(
//                             icon: Icons.show_chart,
//                             color: Colors.deepPurple,
//                             title: "Evolution History",
//                             onTap: () => Navigator.pushNamed(context, '/graph'),
//                           ),
//                         ],
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

// class GlassCard extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String title;
//   final VoidCallback onTap;

//   const GlassCard({
//     super.key,
//     required this.icon,
//     required this.color,
//     required this.title,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Card(
//           elevation: 8,
//           color: Colors.white.withOpacity(0.7),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           margin: const EdgeInsets.symmetric(vertical: 12),
//           child: ListTile(
//             leading: Icon(icon, color: color),
//             title: Text(
//               title,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//             onTap: onTap,
//           ),
//         ),
//       ),
//     );
//   }
// // }
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   User? user;
//   String? username;
//   String? _currentStage;
//   bool _isLoadingStage = true;

//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser;
//     fetchUsername();
//     _fetchCurrentStage();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskForName());
//   }

//   Future<void> fetchUsername() async {
//     final uid = user?.uid;
//     if (uid != null) {
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       setState(() {
//         username = doc.data()?['username'];
//       });
//     }
//   }

//   Future<void> _fetchCurrentStage() async {
//     setState(() => _isLoadingStage = true);

//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .where('type', isEqualTo: 'spiral')
//               .orderBy('timestamp', descending: true)
//               .limit(1)
//               .get();

//       if (snapshot.docs.isNotEmpty) {
//         setState(() {
//           _currentStage = snapshot.docs.first.data()['stage'];
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching stage: $e');
//     } finally {
//       setState(() => _isLoadingStage = false);
//     }
//   }

//   Future<void> _maybeAskForName() async {
//     if (user != null &&
//         (user!.displayName == null || user!.displayName!.isEmpty)) {
//       final name = await _promptForName();
//       if (name != null && name.trim().isNotEmpty) {
//         await user!.updateDisplayName(name.trim());
//         await user!.reload();
//         user = FirebaseAuth.instance.currentUser;
//         setState(() {});
//       }
//     }
//   }

//   Future<String?> _promptForName() async {
//     String enteredName = '';
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Hi there! 👋"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("What should we call you?"),
//                 const SizedBox(height: 12),
//                 TextField(
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     hintText: "Your name",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                   ),
//                   onChanged: (value) => enteredName = value,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(enteredName),
//                 child: const Text("Continue"),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     await GoogleSignIn().signOut();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   Widget _buildStageIndicator() {
//     if (_isLoadingStage) {
//       return const CircularProgressIndicator();
//     }

//     if (_currentStage == null) {
//       return const Text(
//         "No stage detected",
//         style: TextStyle(color: Colors.white, fontSize: 18),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.5),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "CURRENT STAGE",
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 14,
//               fontWeight: FontWeight.w300,
//               letterSpacing: 1.5,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             _currentStage!.toUpperCase(),
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1.2,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final displayName = username ?? user?.displayName ?? "User";
//     final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

//     return Scaffold(
//       drawer: Drawer(
//         child: Stack(
//           children: [
//             ValueListenableBuilder(
//               valueListenable: selectedBgIndex,
//               builder:
//                   (_, index, __) => Image.asset(
//                     bgList[index],
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: double.infinity,
//                   ),
//             ),
//             Container(color: Colors.black.withOpacity(0.5)),
//             SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 30),
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.white.withOpacity(0.8),
//                         child: Text(
//                           initial,
//                           style: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         displayName,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       GlassCard(
//                         icon: Icons.person,
//                         color: Colors.deepPurple,
//                         title: "My Account",
//                         onTap: () async {
//                           await Navigator.pushNamed(context, '/myaccount');
//                           user = FirebaseAuth.instance.currentUser;
//                           await fetchUsername();
//                           setState(() {});
//                         },
//                       ),
//                       GlassCard(
//                         icon: Icons.settings,
//                         color: Colors.blue,
//                         title: "Appearance & Help",
//                         onTap: () => Navigator.pushNamed(context, '/settings'),
//                       ),
//                       GlassCard(
//                         icon: Icons.logout,
//                         color: Colors.red,
//                         title: "Logout",
//                         onTap: _logout,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: selectedBgIndex,
//         builder: (_, index, __) {
//           return Stack(
//             children: [
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 500),
//                 child: Image.asset(
//                   bgList[index],
//                   key: ValueKey(index),
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//               ),
//               Positioned.fill(
//                 child: Container(color: Colors.black.withOpacity(0.4)),
//               ),
//               SafeArea(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       child: Row(
//                         children: [
//                           Builder(
//                             builder:
//                                 (context) => IconButton(
//                                   icon: const Icon(
//                                     Icons.menu,
//                                     color: Colors.white,
//                                   ),
//                                   onPressed:
//                                       () => Scaffold.of(context).openDrawer(),
//                                 ),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.refresh,
//                               color: Colors.white,
//                             ),
//                             onPressed: _fetchCurrentStage,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Welcome, $displayName!',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     _buildStageIndicator(),
//                     const SizedBox(height: 30),
//                     Expanded(
//                       child: ListView(
//                         padding: const EdgeInsets.symmetric(horizontal: 24),
//                         children: [
//                           GlassCard(
//                             icon: Icons.book,
//                             color: Colors.green,
//                             title: "User Guide",
//                             onTap: () => Navigator.pushNamed(context, '/guide'),
//                           ),
//                           GlassCard(
//                             icon: Icons.chat,
//                             color: Colors.indigo,
//                             title: "Reflect & Evolve",
//                             onTap: () => Navigator.pushNamed(context, '/chat'),
//                           ),
//                           GlassCard(
//                             icon: Icons.show_chart,
//                             color: Colors.deepPurple,
//                             title: "Evolution History",
//                             onTap: () => Navigator.pushNamed(context, '/graph'),
//                           ),
//                         ],
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

// class GlassCard extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String title;
//   final VoidCallback onTap;

//   const GlassCard({
//     super.key,
//     required this.icon,
//     required this.color,
//     required this.title,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Card(
//           elevation: 8,
//           color: Colors.white.withOpacity(0.7),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           margin: const EdgeInsets.symmetric(vertical: 12),
//           child: ListTile(
//             leading: Icon(icon, color: color),
//             title: Text(
//               title,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//             onTap: onTap,
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   User? user;
//   String? username;
//   String? _currentStage;
//   bool _isLoadingStage = true;

//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser;
//     fetchUsername();
//     _fetchCurrentStage();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskForName());
//   }

//   Future<void> fetchUsername() async {
//     final uid = user?.uid;
//     if (uid != null) {
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       setState(() {
//         username = doc.data()?['username'];
//       });
//     }
//   }

//   Future<void> _fetchCurrentStage() async {
//     setState(() => _isLoadingStage = true);

//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .orderBy('timestamp', descending: true)
//               .limit(20)
//               .get();

//       print("Fetched ${snapshot.docs.length} messages");

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         print("Doc data: $data");

//         if (data['type'] == 'spiral' &&
//             data['stage'] != null &&
//             data['stage'].toString().trim().isNotEmpty) {
//           setState(() {
//             _currentStage = data['stage'];
//           });
//           break;
//         }
//       }

//       if (_currentStage == null) {
//         print("No valid spiral stage found in recent messages.");
//       }
//     } catch (e) {
//       print('Error while fetching current stage: $e');
//     } finally {
//       setState(() => _isLoadingStage = false);
//     }
//   }

//   Future<void> _maybeAskForName() async {
//     if (user != null &&
//         (user!.displayName == null || user!.displayName!.isEmpty)) {
//       final name = await _promptForName();
//       if (name != null && name.trim().isNotEmpty) {
//         await user!.updateDisplayName(name.trim());
//         await user!.reload();
//         user = FirebaseAuth.instance.currentUser;
//         setState(() {});
//       }
//     }
//   }

//   Future<String?> _promptForName() async {
//     String enteredName = '';
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Hi there! 👋"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("What should we call you?"),
//                 const SizedBox(height: 12),
//                 TextField(
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     hintText: "Your name",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                   ),
//                   onChanged: (value) => enteredName = value,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(enteredName),
//                 child: const Text("Continue"),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     await GoogleSignIn().signOut();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   Widget _buildStageIndicator() {
//     if (_isLoadingStage) {
//       return const CircularProgressIndicator();
//     }

//     if (_currentStage == null) {
//       return const Text(
//         "No stage detected",
//         style: TextStyle(color: Colors.white, fontSize: 18),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.5),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "CURRENT STAGE",
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 14,
//               fontWeight: FontWeight.w300,
//               letterSpacing: 1.5,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             _currentStage!.toUpperCase(),
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1.2,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final displayName = username ?? user?.displayName ?? "User";
//     final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

//     return Scaffold(
//       drawer: Drawer(
//         child: Stack(
//           children: [
//             ValueListenableBuilder(
//               valueListenable: selectedBgIndex,
//               builder:
//                   (_, index, __) => Image.asset(
//                     bgList[index],
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: double.infinity,
//                   ),
//             ),
//             Container(color: Colors.black.withOpacity(0.5)),
//             SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 30),
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.white.withOpacity(0.8),
//                         child: Text(
//                           initial,
//                           style: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         displayName,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       GlassCard(
//                         icon: Icons.person,
//                         color: Colors.deepPurple,
//                         title: "My Account",
//                         onTap: () async {
//                           await Navigator.pushNamed(context, '/myaccount');
//                           user = FirebaseAuth.instance.currentUser;
//                           await fetchUsername();
//                           setState(() {});
//                         },
//                       ),
//                       GlassCard(
//                         icon: Icons.settings,
//                         color: Colors.blue,
//                         title: "Appearance & Help",
//                         onTap: () => Navigator.pushNamed(context, '/settings'),
//                       ),
//                       GlassCard(
//                         icon: Icons.logout,
//                         color: Colors.red,
//                         title: "Logout",
//                         onTap: _logout,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: selectedBgIndex,
//         builder: (_, index, __) {
//           return Stack(
//             children: [
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 500),
//                 child: Image.asset(
//                   bgList[index],
//                   key: ValueKey(index),
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//               ),
//               Positioned.fill(
//                 child: Container(color: Colors.black.withOpacity(0.4)),
//               ),
//               SafeArea(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       child: Row(
//                         children: [
//                           Builder(
//                             builder:
//                                 (context) => IconButton(
//                                   icon: const Icon(
//                                     Icons.menu,
//                                     color: Colors.white,
//                                   ),
//                                   onPressed:
//                                       () => Scaffold.of(context).openDrawer(),
//                                 ),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.refresh,
//                               color: Colors.white,
//                             ),
//                             onPressed: _fetchCurrentStage,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Welcome, $displayName!',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     _buildStageIndicator(),
//                     const SizedBox(height: 30),
//                     Expanded(
//                       child: ListView(
//                         padding: const EdgeInsets.symmetric(horizontal: 24),
//                         children: [
//                           GlassCard(
//                             icon: Icons.book,
//                             color: Colors.green,
//                             title: "User Guide",
//                             onTap: () => Navigator.pushNamed(context, '/guide'),
//                           ),
//                           GlassCard(
//                             icon: Icons.chat,
//                             color: Colors.indigo,
//                             title: "Reflect & Evolve",
//                             onTap: () => Navigator.pushNamed(context, '/chat'),
//                           ),
//                           GlassCard(
//                             icon: Icons.show_chart,
//                             color: Colors.deepPurple,
//                             title: "Evolution History",
//                             onTap: () => Navigator.pushNamed(context, '/graph'),
//                           ),
//                         ],
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

// class GlassCard extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String title;
//   final VoidCallback onTap;

//   const GlassCard({
//     super.key,
//     required this.icon,
//     required this.color,
//     required this.title,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Card(
//           elevation: 8,
//           color: Colors.white.withOpacity(0.7),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           margin: const EdgeInsets.symmetric(vertical: 12),
//           child: ListTile(
//             leading: Icon(icon, color: color),
//             title: Text(
//               title,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//             onTap: onTap,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // [Same imports and class structure]
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   User? user;
//   String? username;
//   String? _currentStage;
//   bool _isLoadingStage = true;

//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser;
//     fetchUsername();
//     _fetchCurrentStage();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskForName());
//   }

//   Future<void> fetchUsername() async {
//     final uid = user?.uid;
//     if (uid != null) {
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       setState(() {
//         username = doc.data()?['username'];
//       });
//     }
//   }

//   Future<void> _fetchCurrentStage() async {
//     setState(() => _isLoadingStage = true);
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .orderBy('timestamp', descending: true)
//               .limit(20)
//               .get();

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         if (data['type'] == 'spiral' &&
//             data['stage'] != null &&
//             data['stage'].toString().trim().isNotEmpty) {
//           setState(() {
//             _currentStage = data['stage'];
//           });
//           break;
//         }
//       }
//     } catch (e) {
//       print('Error while fetching current stage: $e');
//     } finally {
//       setState(() => _isLoadingStage = false);
//     }
//   }

//   Future<void> _maybeAskForName() async {
//     if (user != null &&
//         (user!.displayName == null || user!.displayName!.isEmpty)) {
//       final name = await _promptForName();
//       if (name != null && name.trim().isNotEmpty) {
//         await user!.updateDisplayName(name.trim());
//         await user!.reload();
//         user = FirebaseAuth.instance.currentUser;
//         setState(() {});
//       }
//     }
//   }

//   Future<String?> _promptForName() async {
//     String enteredName = '';
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Hi there! 👋"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("What should we call you?"),
//                 const SizedBox(height: 12),
//                 TextField(
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     hintText: "Your name",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                   ),
//                   onChanged: (value) => enteredName = value,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(enteredName),
//                 child: const Text("Continue"),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     await GoogleSignIn().signOut();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   Widget _buildStageIndicator() {
//     if (_isLoadingStage) {
//       return const CircularProgressIndicator();
//     }

//     if (_currentStage == null) {
//       return const Text(
//         "No stage detected",
//         style: TextStyle(color: Colors.white, fontSize: 18),
//       );
//     }

//     Color bgColor;
//     switch (_currentStage!.toLowerCase()) {
//       case 'red':
//         bgColor = Colors.redAccent;
//         break;
//       case 'blue':
//         bgColor = Colors.blueAccent;
//         break;
//       case 'green':
//         bgColor = Colors.green;
//         break;
//       case 'orange':
//         bgColor = Colors.deepOrange;
//         break;
//       case 'yellow':
//         bgColor = Colors.amber;
//         break;
//       case 'turquoise':
//         bgColor = Colors.teal;
//         break;
//       default:
//         bgColor = Colors.grey;
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             decoration: BoxDecoration(
//               color: bgColor.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white.withOpacity(0.3)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text(
//                   "CURRENT STAGE",
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w300,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   _currentStage!.toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final displayName = username ?? user?.displayName ?? "User";
//     final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

//     return Scaffold(
//       drawer: Drawer(
//         child: Stack(
//           children: [
//             ValueListenableBuilder(
//               valueListenable: selectedBgIndex,
//               builder:
//                   (_, index, __) => Image.asset(
//                     bgList[index],
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: double.infinity,
//                   ),
//             ),
//             Container(color: Colors.black.withOpacity(0.5)),
//             SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 30),
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.white.withOpacity(0.8),
//                         child: Text(
//                           initial,
//                           style: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         displayName,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       GlassCard(
//                         icon: Icons.person,
//                         color: Colors.deepPurple,
//                         title: "My Account",
//                         onTap: () async {
//                           await Navigator.pushNamed(context, '/myaccount');
//                           user = FirebaseAuth.instance.currentUser;
//                           await fetchUsername();
//                           setState(() {});
//                         },
//                       ),
//                       GlassCard(
//                         icon: Icons.settings,
//                         color: Colors.blue,
//                         title: "Appearance & Help",
//                         onTap: () => Navigator.pushNamed(context, '/settings'),
//                       ),
//                       GlassCard(
//                         icon: Icons.logout,
//                         color: Colors.red,
//                         title: "Logout",
//                         onTap: _logout,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: selectedBgIndex,
//         builder: (_, index, __) {
//           return Stack(
//             children: [
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 500),
//                 child: Image.asset(
//                   bgList[index],
//                   key: ValueKey(index),
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//               ),
//               Positioned.fill(
//                 child: Container(color: Colors.black.withOpacity(0.4)),
//               ),
//               SafeArea(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       child: Row(
//                         children: [
//                           Builder(
//                             builder:
//                                 (context) => IconButton(
//                                   icon: const Icon(
//                                     Icons.menu,
//                                     color: Colors.white,
//                                   ),
//                                   onPressed:
//                                       () => Scaffold.of(context).openDrawer(),
//                                 ),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.refresh,
//                               color: Colors.white,
//                             ),
//                             onPressed: _fetchCurrentStage,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Welcome, $displayName!',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     _buildStageIndicator(),
//                     const SizedBox(height: 30),
//                     Expanded(
//                       child: ListView(
//                         padding: const EdgeInsets.symmetric(horizontal: 24),
//                         children: [
//                           GlassCard(
//                             icon: Icons.book,
//                             color: Colors.green,
//                             title: "Spiral Dynamics Guide",
//                             onTap: () => Navigator.pushNamed(context, '/guide'),
//                           ),
//                           GlassCard(
//                             icon: Icons.chat,
//                             color: Colors.indigo,
//                             title: "Reflect & Evolve",
//                             onTap: () => Navigator.pushNamed(context, '/chat'),
//                           ),
//                           GlassCard(
//                             icon: Icons.show_chart,
//                             color: Colors.deepPurple,
//                             title: "Evolution History",
//                             onTap: () => Navigator.pushNamed(context, '/graph'),
//                           ),
//                         ],
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

// class GlassCard extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String title;
//   final VoidCallback onTap;

//   const GlassCard({
//     super.key,
//     required this.icon,
//     required this.color,
//     required this.title,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Card(
//           elevation: 8,
//           color: Colors.white.withOpacity(0.7),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           margin: const EdgeInsets.symmetric(vertical: 12),
//           child: ListTile(
//             leading: Icon(icon, color: color),
//             title: Text(
//               title,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//             onTap: onTap,
//           ),
//         ),
//       ),
//     );
//   }
// }
// // ... all previous imports remain unchanged
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../data/bg_data.dart';
// import '../main.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   User? user;
//   String? username;
//   String? _currentStage;
//   bool _isLoadingStage = true;

//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser;
//     fetchUsername();
//     _fetchCurrentStage();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskForName());
//   }

//   Future<void> fetchUsername() async {
//     final uid = user?.uid;
//     if (uid != null) {
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       setState(() {
//         username = doc.data()?['username'];
//       });
//     }
//   }

//   Future<void> _fetchCurrentStage() async {
//     setState(() => _isLoadingStage = true);
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .orderBy('timestamp', descending: true)
//               .limit(20)
//               .get();

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         if (data['type'] == 'spiral' &&
//             data['stage'] != null &&
//             data['stage'].toString().trim().isNotEmpty) {
//           setState(() {
//             _currentStage = data['stage'];
//           });
//           break;
//         }
//       }
//     } catch (e) {
//       print('Error while fetching current stage: $e');
//     } finally {
//       setState(() => _isLoadingStage = false);
//     }
//   }

//   Future<void> _maybeAskForName() async {
//     if (user != null &&
//         (user!.displayName == null || user!.displayName!.isEmpty)) {
//       final name = await _promptForName();
//       if (name != null && name.trim().isNotEmpty) {
//         await user!.updateDisplayName(name.trim());
//         await user!.reload();
//         user = FirebaseAuth.instance.currentUser;
//         setState(() {});
//       }
//     }
//   }

//   Future<String?> _promptForName() async {
//     String enteredName = '';
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Hi there! 👋"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("What should we call you?"),
//                 const SizedBox(height: 12),
//                 TextField(
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     hintText: "Your name",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                   ),
//                   onChanged: (value) => enteredName = value,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(enteredName),
//                 child: const Text("Continue"),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     await GoogleSignIn().signOut();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   Widget _buildStageIndicator() {
//     if (_isLoadingStage) {
//       return const CircularProgressIndicator();
//     }

//     if (_currentStage == null) {
//       return const Text(
//         "No stage detected",
//         style: TextStyle(color: Colors.white, fontSize: 18),
//       );
//     }

//     Color bgColor;
//     switch (_currentStage!.toLowerCase()) {
//       case 'red':
//         bgColor = Colors.redAccent;
//         break;
//       case 'blue':
//         bgColor = Colors.blueAccent;
//         break;
//       case 'green':
//         bgColor = Colors.green;
//         break;
//       case 'orange':
//         bgColor = Colors.deepOrange;
//         break;
//       case 'yellow':
//         bgColor = Colors.amber;
//         break;
//       case 'turquoise':
//         bgColor = Colors.teal;
//         break;
//       default:
//         bgColor = Colors.grey;
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             decoration: BoxDecoration(
//               color: bgColor.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white.withOpacity(0.3)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text(
//                   "CURRENT STAGE",
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w300,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   _currentStage!.toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final displayName = username ?? user?.displayName ?? "User";
//     final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

//     return Scaffold(
//       drawer: Drawer(
//         child: Stack(
//           children: [
//             ValueListenableBuilder(
//               valueListenable: selectedBgIndex,
//               builder:
//                   (_, index, __) => Image.asset(
//                     bgList[index],
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: double.infinity,
//                   ),
//             ),
//             Container(color: Colors.black.withOpacity(0.5)),
//             SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 30),
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.white.withOpacity(0.8),
//                         child: Text(
//                           initial,
//                           style: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         displayName,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       GlassCard(
//                         icon: Icons.person,
//                         color: Colors.deepPurple,
//                         title: "My Account",
//                         onTap: () async {
//                           await Navigator.pushNamed(context, '/myaccount');
//                           user = FirebaseAuth.instance.currentUser;
//                           await fetchUsername();
//                           setState(() {});
//                         },
//                       ),
//                       GlassCard(
//                         icon: Icons.settings,
//                         color: Colors.blue,
//                         title: "Appearance & Help",
//                         onTap: () => Navigator.pushNamed(context, '/settings'),
//                       ),
//                       GlassCard(
//                         icon: Icons.logout,
//                         color: Colors.red,
//                         title: "Logout",
//                         onTap: _logout,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: selectedBgIndex,
//         builder: (_, index, __) {
//           return Stack(
//             children: [
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 500),
//                 child: Image.asset(
//                   bgList[index],
//                   key: ValueKey(index),
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//               ),
//               Positioned.fill(
//                 child: Container(color: Colors.black.withOpacity(0.4)),
//               ),
//               SafeArea(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       child: Row(
//                         children: [
//                           Builder(
//                             builder:
//                                 (context) => IconButton(
//                                   icon: const Icon(
//                                     Icons.menu,
//                                     color: Colors.white,
//                                   ),
//                                   onPressed:
//                                       () => Scaffold.of(context).openDrawer(),
//                                 ),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.refresh,
//                               color: Colors.white,
//                             ),
//                             onPressed: _fetchCurrentStage,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Welcome, $displayName!',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     _buildStageIndicator(),
//                     const SizedBox(height: 30),
//                     Expanded(
//                       child: ListView(
//                         padding: const EdgeInsets.symmetric(horizontal: 24),
//                         children: [
//                           GlassCard(
//                             icon: Icons.book,
//                             color: Colors.green,
//                             title: "Spiral Dynamics Guide",
//                             onTap: () => Navigator.pushNamed(context, '/guide'),
//                           ),
//                           GlassCard(
//                             icon: Icons.explore,
//                             color: Colors.orange,
//                             title: "Journey Guide",
//                             onTap:
//                                 () => Navigator.pushNamed(
//                                   context,
//                                   '/journeyguide',
//                                 ),
//                           ),
//                           GlassCard(
//                             icon: Icons.chat,
//                             color: Colors.indigo,
//                             title: "Reflect & Evolve",
//                             onTap: () => Navigator.pushNamed(context, '/chat'),
//                           ),
//                           GlassCard(
//                             icon: Icons.show_chart,
//                             color: Colors.deepPurple,
//                             title: "Evolution History",
//                             onTap: () => Navigator.pushNamed(context, '/graph'),
//                           ),
//                         ],
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

// class GlassCard extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String title;
//   final VoidCallback onTap;

//   const GlassCard({
//     super.key,
//     required this.icon,
//     required this.color,
//     required this.title,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Card(
//           elevation: 8,
//           color: Colors.white.withOpacity(0.7),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           margin: const EdgeInsets.symmetric(vertical: 12),
//           child: ListTile(
//             leading: Icon(icon, color: color),
//             title: Text(
//               title,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//             onTap: onTap,
//           ),
//         ),
//       ),
//     );
//   }
// // }
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../main.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   User? user;
//   String? username;
//   String? _currentStage;
//   bool _isLoadingStage = true;

//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser;
//     fetchUsername();
//     _fetchCurrentStage();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskForName());
//   }

//   Future<void> fetchUsername() async {
//     final uid = user?.uid;
//     if (uid != null) {
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       setState(() {
//         username = doc.data()?['username'];
//       });
//     }
//   }

//   Future<void> _fetchCurrentStage() async {
//     setState(() => _isLoadingStage = true);
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .orderBy('timestamp', descending: true)
//               .limit(20)
//               .get();

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         if (data['type'] == 'spiral' &&
//             data['stage'] != null &&
//             data['stage'].toString().trim().isNotEmpty) {
//           setState(() {
//             _currentStage = data['stage'];
//           });
//           break;
//         }
//       }
//     } catch (e) {
//       print('Error while fetching current stage: $e');
//     } finally {
//       setState(() => _isLoadingStage = false);
//     }
//   }

//   Future<void> _maybeAskForName() async {
//     if (user != null &&
//         (user!.displayName == null || user!.displayName!.isEmpty)) {
//       final name = await _promptForName();
//       if (name != null && name.trim().isNotEmpty) {
//         await user!.updateDisplayName(name.trim());
//         await user!.reload();
//         user = FirebaseAuth.instance.currentUser;
//         setState(() {});
//       }
//     }
//   }

//   Future<String?> _promptForName() async {
//     String enteredName = '';
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Hi there! 👋"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("What should we call you?"),
//                 const SizedBox(height: 12),
//                 TextField(
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     hintText: "Your name",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                   ),
//                   onChanged: (value) => enteredName = value,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(enteredName),
//                 child: const Text("Continue"),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     await GoogleSignIn().signOut();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   Widget _buildStageIndicator() {
//     if (_isLoadingStage) {
//       return const CircularProgressIndicator();
//     }

//     if (_currentStage == null) {
//       return const Text(
//         "No stage detected",
//         style: TextStyle(color: Colors.grey, fontSize: 18),
//       );
//     }

//     Color bgColor;
//     switch (_currentStage!.toLowerCase()) {
//       case 'red':
//         bgColor = Colors.redAccent;
//         break;
//       case 'blue':
//         bgColor = Colors.blueAccent;
//         break;
//       case 'green':
//         bgColor = Colors.green;
//         break;
//       case 'orange':
//         bgColor = Colors.deepOrange;
//         break;
//       case 'yellow':
//         bgColor = Colors.amber;
//         break;
//       case 'turquoise':
//         bgColor = Colors.teal;
//         break;
//       default:
//         bgColor = Colors.grey;
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       decoration: BoxDecoration(
//         color: bgColor.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Center(
//         child: Column(
//           children: [
//             const Text(
//               "CURRENT STAGE",
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//                 letterSpacing: 1.5,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _currentStage!.toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
//     final displayName = username ?? user?.displayName ?? "User";
//     final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: Builder(
//           builder:
//               (context) => IconButton(
//                 icon: Icon(Icons.menu, color: textColor),
//                 onPressed: () => Scaffold.of(context).openDrawer(),
//               ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh, color: textColor),
//             onPressed: _fetchCurrentStage,
//           ),
//           IconButton(
//             icon: Icon(
//               isDark ? Icons.light_mode : Icons.dark_mode,
//               color: textColor,
//             ),
//             onPressed: () {
//               themeModeNotifier.value =
//                   isDark ? ThemeMode.light : ThemeMode.dark;
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               decoration: const BoxDecoration(color: Colors.deepPurple),
//               accountName: Text(displayName),
//               accountEmail: Text(user?.email ?? ''),
//               currentAccountPicture: CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: Text(
//                   initial,
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text("My Account"),
//               onTap: () async {
//                 await Navigator.pushNamed(context, '/myaccount');
//                 user = FirebaseAuth.instance.currentUser;
//                 await fetchUsername();
//                 setState(() {});
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text("Help"),
//               onTap: () => Navigator.pushNamed(context, '/settings'),
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text("Logout"),
//               onTap: _logout,
//             ),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       'Welcome, $displayName!',
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: textColor,
//                       ),
//                     ),
//                     _buildStageIndicator(),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 20,
//                   crossAxisSpacing: 20,
//                   padding: const EdgeInsets.only(top: 30),
//                   children: [
//                     _buildTile(
//                       Icons.book,
//                       "Spiral Guide",
//                       Colors.green,
//                       '/guide',
//                     ),
//                     _buildTile(
//                       Icons.explore,
//                       "Journey Guide",
//                       Colors.orange,
//                       '/journeyguide',
//                     ),
//                     _buildTile(
//                       Icons.chat,
//                       "Reflect & Evolve",
//                       Colors.indigo,
//                       '/chat',
//                     ),
//                     _buildTile(
//                       Icons.show_chart,
//                       "Your Growth",
//                       Colors.purple,
//                       '/graph',
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTile(
//     IconData icon,
//     String title,
//     Color color,
//     String routeName,
//   ) {
//     return GestureDetector(
//       onTap: () => Navigator.pushNamed(context, routeName),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.4),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Colors.white),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../main.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   User? user;
//   String? username;
//   String? _currentStage;
//   bool _isLoadingStage = true;

//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser;
//     fetchUsername();
//     _fetchCurrentStage();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskForName());
//   }

//   Future<void> fetchUsername() async {
//     final uid = user?.uid;
//     if (uid != null) {
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       setState(() {
//         username = doc.data()?['username'];
//       });
//     }
//   }

//   Future<void> _fetchCurrentStage() async {
//     setState(() => _isLoadingStage = true);
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .orderBy('timestamp', descending: true)
//               .limit(20)
//               .get();

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         if (data['type'] == 'spiral' &&
//             data['stage'] != null &&
//             data['stage'].toString().trim().isNotEmpty) {
//           setState(() {
//             _currentStage = data['stage'];
//           });
//           break;
//         }
//       }
//     } catch (e) {
//       print('Error while fetching current stage: $e');
//     } finally {
//       setState(() => _isLoadingStage = false);
//     }
//   }

//   Future<void> _maybeAskForName() async {
//     if (user != null &&
//         (user!.displayName == null || user!.displayName!.isEmpty)) {
//       final name = await _promptForName();
//       if (name != null && name.trim().isNotEmpty) {
//         await user!.updateDisplayName(name.trim());
//         await user!.reload();
//         user = FirebaseAuth.instance.currentUser;
//         setState(() {});
//       }
//     }
//   }

//   Future<String?> _promptForName() async {
//     String enteredName = '';
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Hi there! 👋"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("What should we call you?"),
//                 const SizedBox(height: 12),
//                 TextField(
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     hintText: "Your name",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                   ),
//                   onChanged: (value) => enteredName = value,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(enteredName),
//                 child: const Text("Continue"),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     await GoogleSignIn().signOut();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   Widget _buildStageIndicator() {
//     if (_isLoadingStage) {
//       return const CircularProgressIndicator();
//     }

//     if (_currentStage == null) {
//       return const Text(
//         "No stage detected",
//         style: TextStyle(color: Colors.grey, fontSize: 18),
//       );
//     }

//     Color bgColor;
//     switch (_currentStage!.toLowerCase()) {
//       case 'red':
//         bgColor = Colors.redAccent;
//         break;
//       case 'blue':
//         bgColor = Colors.blueAccent;
//         break;
//       case 'green':
//         bgColor = Colors.green;
//         break;
//       case 'orange':
//         bgColor = Colors.deepOrange;
//         break;
//       case 'yellow':
//         bgColor = Colors.amber;
//         break;
//       case 'turquoise':
//         bgColor = Colors.teal;
//         break;
//       default:
//         bgColor = Colors.grey;
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       decoration: BoxDecoration(
//         color: bgColor.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Center(
//         child: Column(
//           children: [
//             const Text(
//               "CURRENT STAGE",
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//                 letterSpacing: 1.5,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _currentStage!.toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
//     final displayName = username ?? user?.displayName ?? "User";
//     final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: Builder(
//           builder:
//               (context) => IconButton(
//                 icon: Icon(Icons.menu, color: textColor),
//                 onPressed: () => Scaffold.of(context).openDrawer(),
//               ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh, color: textColor),
//             onPressed: _fetchCurrentStage,
//           ),
//           IconButton(
//             icon: Icon(
//               isDark ? Icons.light_mode : Icons.dark_mode,
//               color: textColor,
//             ),
//             onPressed: () {
//               themeModeNotifier.value =
//                   isDark ? ThemeMode.light : ThemeMode.dark;
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserAccountsDrawerHeader(
//               decoration: const BoxDecoration(color: Colors.deepPurple),
//               accountName: Text(displayName),
//               accountEmail: null, // Removed email
//               currentAccountPicture: CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: Text(
//                   initial,
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text("My Account"),
//               onTap: () async {
//                 await Navigator.pushNamed(context, '/myaccount');
//                 user = FirebaseAuth.instance.currentUser;
//                 await fetchUsername();
//                 setState(() {});
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text("Help"),
//               onTap: () => Navigator.pushNamed(context, '/settings'),
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text("Logout"),
//               onTap: _logout,
//             ),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       'Welcome, $displayName!',
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: textColor,
//                       ),
//                     ),
//                     _buildStageIndicator(),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 20,
//                   crossAxisSpacing: 20,
//                   padding: const EdgeInsets.only(top: 30),
//                   children: [
//                     _buildTile(
//                       Icons.book,
//                       "Spiral Guide",
//                       Colors.green,
//                       '/guide',
//                     ),
//                     _buildTile(
//                       Icons.explore,
//                       "Journey Guide",
//                       Colors.orange,
//                       '/journeyguide',
//                     ),
//                     _buildTile(
//                       Icons.chat,
//                       "Reflect & Evolve",
//                       Colors.indigo,
//                       '/chat',
//                     ),
//                     _buildTile(
//                       Icons.show_chart,
//                       "Your Growth",
//                       Colors.purple,
//                       '/graph',
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTile(
//     IconData icon,
//     String title,
//     Color color,
//     String routeName,
//   ) {
//     return GestureDetector(
//       onTap: () => Navigator.pushNamed(context, routeName),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.4),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Colors.white),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../main.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   User? user;
//   String? username;
//   String? _currentStage;
//   bool _isLoadingStage = true;

//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser;
//     fetchUsername();
//     _fetchCurrentStage();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskForName());
//   }

//   Future<void> fetchUsername() async {
//     final uid = user?.uid;
//     if (uid != null) {
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       setState(() {
//         username = doc.data()?['username'];
//       });
//     }
//   }

//   Future<void> _fetchCurrentStage() async {
//     setState(() => _isLoadingStage = true);
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .orderBy('timestamp', descending: true)
//               .limit(20)
//               .get();

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         if (data['type'] == 'spiral' &&
//             data['stage'] != null &&
//             data['stage'].toString().trim().isNotEmpty) {
//           setState(() {
//             _currentStage = data['stage'];
//           });
//           break;
//         }
//       }
//     } catch (e) {
//       print('Error while fetching current stage: $e');
//     } finally {
//       setState(() => _isLoadingStage = false);
//     }
//   }

//   Future<void> _maybeAskForName() async {
//     if (user != null &&
//         (user!.displayName == null || user!.displayName!.isEmpty)) {
//       final name = await _promptForName();
//       if (name != null && name.trim().isNotEmpty) {
//         await user!.updateDisplayName(name.trim());
//         await user!.reload();
//         user = FirebaseAuth.instance.currentUser;
//         setState(() {});
//       }
//     }
//   }

//   Future<String?> _promptForName() async {
//     String enteredName = '';
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Hi there! 👋"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("What should we call you?"),
//                 const SizedBox(height: 12),
//                 TextField(
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     hintText: "Your name",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                   ),
//                   onChanged: (value) => enteredName = value,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(enteredName),
//                 child: const Text("Continue"),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     await GoogleSignIn().signOut();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   Widget _buildStageIndicator() {
//     if (_isLoadingStage) {
//       return const CircularProgressIndicator();
//     }

//     if (_currentStage == null) {
//       return const Text(
//         "No stage detected",
//         style: TextStyle(color: Colors.grey, fontSize: 18),
//       );
//     }

//     Color bgColor;
//     switch (_currentStage!.toLowerCase()) {
//       case 'red':
//         bgColor = Colors.redAccent;
//         break;
//       case 'blue':
//         bgColor = Colors.blueAccent;
//         break;
//       case 'green':
//         bgColor = Colors.green;
//         break;
//       case 'orange':
//         bgColor = Colors.deepOrange;
//         break;
//       case 'yellow':
//         bgColor = Colors.amber;
//         break;
//       case 'turquoise':
//         bgColor = Colors.teal;
//         break;
//       default:
//         bgColor = Colors.grey;
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       decoration: BoxDecoration(
//         color: bgColor.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Center(
//         child: Column(
//           children: [
//             const Text(
//               "CURRENT STAGE",
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//                 letterSpacing: 1.5,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _currentStage!.toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
//     final displayName = username ?? user?.displayName ?? "User";
//     final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: Builder(
//           builder:
//               (context) => IconButton(
//                 icon: Icon(Icons.menu, color: textColor),
//                 onPressed: () => Scaffold.of(context).openDrawer(),
//               ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh, color: textColor),
//             onPressed: _fetchCurrentStage,
//           ),
//           IconButton(
//             icon: Icon(
//               isDark ? Icons.light_mode : Icons.dark_mode,
//               color: textColor,
//             ),
//             onPressed: () {
//               themeModeNotifier.value =
//                   isDark ? ThemeMode.light : ThemeMode.dark;
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Colors.deepPurple),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.white,
//                     child: Text(
//                       initial,
//                       style: const TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     displayName,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 12),
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.person),
//                     title: const Text("My Account"),
//                     onTap: () async {
//                       await Navigator.pushNamed(context, '/myaccount');
//                       user = FirebaseAuth.instance.currentUser;
//                       await fetchUsername();
//                       setState(() {});
//                     },
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.settings),
//                     title: const Text("Help"),
//                     onTap: () => Navigator.pushNamed(context, '/settings'),
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.logout),
//                     title: const Text("Logout"),
//                     onTap: _logout,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       'Welcome, $displayName!',
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: textColor,
//                       ),
//                     ),
//                     _buildStageIndicator(),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 20,
//                   crossAxisSpacing: 20,
//                   padding: const EdgeInsets.only(top: 30),
//                   children: [
//                     _buildTile(
//                       Icons.book,
//                       "Spiral Guide",
//                       Colors.green,
//                       '/guide',
//                     ),
//                     _buildTile(
//                       Icons.explore,
//                       "Journey Guide",
//                       Colors.orange,
//                       '/journeyguide',
//                     ),
//                     _buildTile(
//                       Icons.chat,
//                       "Reflect & Evolve",
//                       Colors.indigo,
//                       '/chat',
//                     ),
//                     _buildTile(
//                       Icons.show_chart,
//                       "Your Growth",
//                       Colors.purple,
//                       '/graph',
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTile(
//     IconData icon,
//     String title,
//     Color color,
//     String routeName,
//   ) {
//     return GestureDetector(
//       onTap: () => Navigator.pushNamed(context, routeName),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.4),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Colors.white),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// // }
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../main.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   User? user;
//   String? username;
//   String? _currentStage;
//   bool _isLoadingStage = true;

//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser;
//     fetchUsername();
//     _fetchCurrentStage();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskForName());
//   }

//   Future<void> fetchUsername() async {
//     final uid = user?.uid;
//     if (uid != null) {
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       setState(() {
//         username = doc.data()?['username'];
//       });
//     }
//   }

//   Future<void> _fetchCurrentStage() async {
//     setState(() => _isLoadingStage = true);
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user!.uid)
//               .collection('mergedMessages')
//               .orderBy('timestamp', descending: true)
//               .limit(20)
//               .get();

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         if (data['type'] == 'spiral' &&
//             data['stage'] != null &&
//             data['stage'].toString().trim().isNotEmpty) {
//           setState(() {
//             _currentStage = data['stage'];
//           });
//           break;
//         }
//       }
//     } catch (e) {
//       print('Error while fetching current stage: $e');
//     } finally {
//       setState(() => _isLoadingStage = false);
//     }
//   }

//   Future<void> _maybeAskForName() async {
//     if (user != null &&
//         (user!.displayName == null || user!.displayName!.isEmpty)) {
//       final name = await _promptForName();
//       if (name != null && name.trim().isNotEmpty) {
//         await user!.updateDisplayName(name.trim());
//         await user!.reload();
//         user = FirebaseAuth.instance.currentUser;
//         setState(() {});
//       }
//     }
//   }

//   Future<String?> _promptForName() async {
//     String enteredName = '';
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Hi there! 👋"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("What should we call you?"),
//                 const SizedBox(height: 12),
//                 TextField(
//                   autofocus: true,
//                   decoration: InputDecoration(
//                     hintText: "Your name",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                   ),
//                   onChanged: (value) => enteredName = value,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(enteredName),
//                 child: const Text("Continue"),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     await GoogleSignIn().signOut();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   Widget _buildStageIndicator() {
//     if (_isLoadingStage) {
//       return const CircularProgressIndicator();
//     }

//     if (_currentStage == null) {
//       return const Text(
//         "No stage detected",
//         style: TextStyle(color: Colors.grey, fontSize: 18),
//       );
//     }

//     Color bgColor;
//     switch (_currentStage!.toLowerCase()) {
//       case 'red':
//         bgColor = Colors.redAccent;
//         break;
//       case 'blue':
//         bgColor = Colors.blueAccent;
//         break;
//       case 'green':
//         bgColor = Colors.green;
//         break;
//       case 'orange':
//         bgColor = Colors.deepOrange;
//         break;
//       case 'yellow':
//         bgColor = Colors.amber;
//         break;
//       case 'turquoise':
//         bgColor = Colors.teal;
//         break;
//       default:
//         bgColor = Colors.grey;
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       decoration: BoxDecoration(
//         color: bgColor.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Center(
//         child: Column(
//           children: [
//             const Text(
//               "CURRENT STAGE",
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//                 letterSpacing: 1.5,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _currentStage!.toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final appBarBg =
//         Theme.of(context).appBarTheme.backgroundColor ??
//         Theme.of(context).colorScheme.primary;
//     final appBarFg =
//         Theme.of(context).appBarTheme.foregroundColor ??
//         Theme.of(context).colorScheme.onPrimary;

//     final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
//     final displayName = username ?? user?.displayName ?? "User";
//     final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text(
//           'RETᐯRN',
//           style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
//         ),
//         backgroundColor: appBarBg,
//         foregroundColor: appBarFg,
//         elevation: 2,
//         leading: IconButton(
//           icon: Icon(Icons.menu, color: appBarFg),
//           onPressed: () => Scaffold.of(context).openDrawer(),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh, color: appBarFg),
//             onPressed: _fetchCurrentStage,
//           ),
//           IconButton(
//             icon: Icon(
//               isDark ? Icons.light_mode : Icons.dark_mode,
//               color: appBarFg,
//             ),
//             onPressed: () {
//               themeModeNotifier.value =
//                   isDark ? ThemeMode.light : ThemeMode.dark;
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Colors.deepPurple),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.white,
//                     child: Text(
//                       initial,
//                       style: const TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     displayName,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 12),
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.person),
//                     title: const Text("My Account"),
//                     onTap: () async {
//                       await Navigator.pushNamed(context, '/myaccount');
//                       user = FirebaseAuth.instance.currentUser;
//                       await fetchUsername();
//                       setState(() {});
//                     },
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.settings),
//                     title: const Text("Help"),
//                     onTap: () => Navigator.pushNamed(context, '/settings'),
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.logout),
//                     title: const Text("Logout"),
//                     onTap: _logout,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       'Welcome, $displayName!',
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: textColor,
//                       ),
//                     ),
//                     _buildStageIndicator(),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 20,
//                   crossAxisSpacing: 20,
//                   padding: const EdgeInsets.only(top: 30),
//                   children: [
//                     _buildTile(
//                       Icons.book,
//                       "Spiral Guide",
//                       Colors.green,
//                       '/guide',
//                     ),
//                     _buildTile(
//                       Icons.explore,
//                       "Journey Guide",
//                       Colors.orange,
//                       '/journeyguide',
//                     ),
//                     _buildTile(
//                       Icons.chat,
//                       "Reflect & Evolve",
//                       Colors.indigo,
//                       '/chat',
//                     ),
//                     _buildTile(
//                       Icons.show_chart,
//                       "Your Growth",
//                       Colors.purple,
//                       '/graph',
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTile(
//     IconData icon,
//     String title,
//     Color color,
//     String routeName,
//   ) {
//     return GestureDetector(
//       onTap: () => Navigator.pushNamed(context, routeName),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.4),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Colors.white),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui';
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
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildStageIndicator() {
    if (_isLoadingStage) {
      return const CircularProgressIndicator();
    }

    if (_currentStage == null) {
      return const Text(
        "No stage detected",
        style: TextStyle(color: Colors.grey, fontSize: 18),
      );
    }

    Color bgColor;
    switch (_currentStage!.toLowerCase()) {
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
              _currentStage!.toUpperCase(),
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
          // FIX: Added Builder so openDrawer works
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
