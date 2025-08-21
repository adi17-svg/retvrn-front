import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/merged_reflect_screen.dart';
import 'screens/user_guide_screen.dart';
import 'screens/spiral_evolution_chart.dart';
import 'screens/my_account_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/journey_guide_screen.dart';

final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _storeMessageOnce(RemoteMessage message) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final now = DateTime.now();
  final todayStart =
      DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('mergedMessages')
            .where('created_at', isGreaterThanOrEqualTo: todayStart)
            .where('from', isEqualTo: 'system')
            .get();

    if (snapshot.docs.isNotEmpty) {
      debugPrint("⚠ Bot message already exists today, skipping.");
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mergedMessages')
        .add({
          'type': 'spiral',
          'stage': 'inner_compass',
          'question':
              'Recall a time when your only focus was to make it through the day. What mattered most in that moment?',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'from': 'system',
        });

    debugPrint("✅ Bot message stored once.");
  } catch (e) {
    debugPrint("❌ Error storing message: $e");
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _storeMessageOnce(message);

  if (message.data['screen'] == 'chat') {
    navigatorKey.currentState?.pushNamed('/chat');
  }
}

Future<void> setupFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  // Request permissions
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // Get token and subscribe to topics
  String? token = await messaging.getToken();
  final user = FirebaseAuth.instance.currentUser;
  if (user != null && token != null) {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "fcmToken": token,
    }, SetOptions(merge: true));

    // ✅ Keep per-user topic (optional)
    await messaging.subscribeToTopic("user_${user.uid}");

    // ✅ Subscribe all users to shared "daily_task" topic
    await messaging.subscribeToTopic("daily_task");
  }

  // Background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Foreground handler for daily tasks
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.data['type'] == 'daily_task') {
      final prefs = await SharedPreferences.getInstance();
      final lastTaskDate = prefs.getString('lastDailyTaskDate');
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (lastTaskDate != today) {
        await prefs.setString('lastDailyTaskDate', today);

        // ✅ Show notification here (currently stubbed, depends on your UI/notification package)
        debugPrint("📩 Daily task received: ${message.data['task']}");
      } else {
        debugPrint("⚠ Already notified today, skipping.");
      }
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    if (message.data['type'] == 'daily_task') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastDailyTask');
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    if (message.data['screen'] == 'chat') {
      navigatorKey.currentState?.pushNamed('/chat');
    }
  });

  // Terminated app handling
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null && initialMessage.data['screen'] == 'chat') {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamed('/chat');
    });
  }

  // Refresh token listener
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "fcmToken": newToken,
      }, SetOptions(merge: true));

      await messaging.subscribeToTopic("user_${user.uid}");
      await messaging.subscribeToTopic("daily_task"); // ✅ Ensure re-subscribed
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFirebaseMessaging();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RETVRN',
          navigatorKey: navigatorKey,
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: Colors.deepPurple,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
            ),
            useMaterial3: true,
          ),
          home: const AuthGate(),
          routes: {
            '/welcome': (_) => const WelcomeScreen(),
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/home': (_) => const HomeScreen(),
            '/chat': (_) => const MergedReflectScreen(),
            '/guide': (_) => const UserGuideScreen(),
            '/journeyguide': (_) => const JourneyGuideScreen(),
            '/graph': (_) => const SpiralEvolutionChartScreen(),
            '/myaccount': (_) => const MyAccountScreen(),
            '/settings': (_) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> _subscribeToUserTopic() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseMessaging.instance.subscribeToTopic('user_${user.uid}');
      await FirebaseMessaging.instance.subscribeToTopic(
        'daily_task',
      ); // ✅ Added here too
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _subscribeToUserTopic();
          });
          return const HomeScreen();
        }
        return const WelcomeScreen();
      },
    );
  }
}
