// import 'package:flutter/material.dart';

// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Spacer(flex: 2),

//               // App Logo Placeholder (optional)
//               Icon(Icons.bubble_chart_rounded, size: 80, color: Colors.black87),

//               const SizedBox(height: 16),

//               // App Title
//               const Text(
//                 'Welcome to RETVRN',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: 32),

//               // Sign In Button (Green)
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF00C853), // Green
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   elevation: 4,
//                 ),
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/login');
//                 },
//                 child: const Text('Sign In', style: TextStyle(fontSize: 18)),
//               ),

//               const SizedBox(height: 16),

//               // Sign Up Button (Orange)
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFF9100), // Orange
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   elevation: 4,
//                 ),
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/register');
//                 },
//                 child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
//               ),

//               const Spacer(flex: 3),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../main.dart'; // for themeModeNotifier

// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final iconColor = textColor;
//     const signInColor = Color(0xFF00C853); // Green
//     const signUpColor = Color(0xFFFF9100); // Orange

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             children: [
//               // Theme Toggle Button
//               Align(
//                 alignment: Alignment.topRight,
//                 child: IconButton(
//                   icon: Icon(
//                     isDark ? Icons.light_mode : Icons.dark_mode,
//                     color: textColor,
//                   ),
//                   onPressed: () {
//                     themeModeNotifier.value =
//                         isDark ? ThemeMode.light : ThemeMode.dark;
//                   },
//                 ),
//               ),

//               const Spacer(flex: 2),

//               // App Logo
//               Icon(Icons.bubble_chart_rounded, size: 80, color: iconColor),

//               const SizedBox(height: 16),

//               // App Title
//               Text(
//                 'Welcome to RETVRN',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: 32),

//               // Sign In Button
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: signInColor,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   elevation: 4,
//                 ),
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/login');
//                 },
//                 child: const Text('Sign In', style: TextStyle(fontSize: 18)),
//               ),

//               const SizedBox(height: 16),

//               // Sign Up Button
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: signUpColor,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   elevation: 4,
//                 ),
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/register');
//                 },
//                 child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
//               ),

//               const Spacer(flex: 3),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../main.dart'; // for themeModeNotifier

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconColor = textColor;
    const signInColor = Color(0xFFFF9100); // Orange
    const signUpColor = Color(0xFF00C853); // Green

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Theme Toggle Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: textColor,
                  ),
                  onPressed: () {
                    themeModeNotifier.value =
                        isDark ? ThemeMode.light : ThemeMode.dark;
                  },
                ),
              ),

              const Spacer(flex: 2),

              // App Logo
              Icon(Icons.bubble_chart_rounded, size: 80, color: iconColor),

              const SizedBox(height: 16),

              // App Title
              Text(
                'Welcome to RETVRN',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Sign In Button (Now Orange)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: signInColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Sign In', style: TextStyle(fontSize: 18)),
              ),

              const SizedBox(height: 16),

              // Sign Up Button (Now Green)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: signUpColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
