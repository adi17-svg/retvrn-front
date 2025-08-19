// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// import 'data/bg_data.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart'; // ✅ Welcome screen

// // Global ValueNotifier to manage selected background index
// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: selectedBgIndex,
//       builder: (context, index, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           theme: ThemeData(
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//           ),
//           initialRoute: '/welcome',
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// import 'data/bg_data.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';

// // Global notifiers
// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           initialRoute: '/welcome',
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// import 'data/bg_data.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart'; // ✅ New import added

// // Global notifiers
// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           initialRoute: '/welcome',
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const JourneyGuideScreen(), // ✅ Route updated
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// import 'data/bg_data.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart'; // Spiral Dynamics Guide
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart'; // ✅ Journal Guide

// // Global notifiers
// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           initialRoute: '/welcome',
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(), // ✅ Spiral Dynamics Guide
//             '/journeyguide':
//                 (_) => const JourneyGuideScreen(), // ✅ Journal Guide
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// // // }
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// import 'data/bg_data.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart';

// // Global notifiers
// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           navigatorKey: navigatorKey,
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           initialRoute: '/welcome',
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/journeyguide': (_) => const JourneyGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }
// main.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart';

// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   tz.initializeTimeZones();
//   await NotificationService().init();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialAp  p(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           navigatorKey: navigatorKey,
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           home: const AuthGate(), // 👈 this decides where to go
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/journeyguide': (_) => const JourneyGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }

// /// This widget listens to Firebase auth state and routes accordingly
// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // Still loading Firebase
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         // User is logged in
//         if (snapshot.hasData) {
//           return const HomeScreen();
//         }
//         // No user logged in
//         return const WelcomeScreen();
//       },
//     );
//   }
// }

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   NotificationService._internal();

//   Future<void> init() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   Future<void> showNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//           'daily_notif_channel',
//           'Daily Notifications',
//           channelDescription: 'Channel for daily reminders',
//           importance: Importance.max,
//           priority: Priority.high,
//         );

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       const NotificationDetails(android: androidDetails),
//     );
//   }

//   Future<void> scheduleDailyNotification({
//     required int hour,
//     required int minute,
//     required String title,
//     required String body,
//   }) async {
//     final androidDetails = const AndroidNotificationDetails(
//       'daily_notif_channel',
//       'Daily Notifications',
//       channelDescription: 'Daily reminder channel',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     final platformDetails = NotificationDetails(android: androidDetails);

//     final scheduledTime = _nextInstanceOfTime(hour, minute);
//     debugPrint("Scheduling notification for: $scheduledTime");

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       title,
//       body,
//       scheduledTime,
//       platformDetails,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
//     );
//   }

//   tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
//     final now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       hour,
//       minute,
//     );
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }
//     return scheduledDate;
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// // Your screens
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart';

// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   tz.initializeTimeZones();
//   await NotificationService().init();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           navigatorKey: navigatorKey,
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           home: const AuthGate(),
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/journeyguide': (_) => const JourneyGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasData) {
//           return const HomeScreenWithNotifications(); // wrapped with notif logic
//         }
//         return const WelcomeScreen();
//       },
//     );
//   }
// }

// /// Wrapper around HomeScreen that handles notifications
// class HomeScreenWithNotifications extends StatefulWidget {
//   const HomeScreenWithNotifications({super.key});

//   @override
//   State<HomeScreenWithNotifications> createState() =>
//       _HomeScreenWithNotificationsState();
// }

// class _HomeScreenWithNotificationsState
//     extends State<HomeScreenWithNotifications> {
//   @override
//   void initState() {
//     super.initState();
//     _requestNotificationPermission();
//   }

//   Future<void> _requestNotificationPermission() async {
//     var status = await Permission.notification.status;

//     if (!status.isGranted) {
//       final result = await Permission.notification.request();
//       if (result.isGranted) {
//         _setupNotifications();
//       }
//     } else {
//       _setupNotifications();
//     }
//   }

//   void _setupNotifications() {
//     _showWelcomeDialog();
//     NotificationService().showNotification(
//       title: 'Welcome!',
//       body: 'Notifications enabled.',
//     );

//     NotificationService().scheduleDailyNotification(
//       hour: 23,
//       minute: 24,
//       title: 'Daily Reminder',
//       body: 'This is your daily notification!',
//     );
//   }

//   void _showWelcomeDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Welcome!'),
//             content: const Text('Thank you for allowing notifications.'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const HomeScreen();
//   }
// }

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   NotificationService._internal();

//   Future<void> init() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   Future<void> showNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//           'daily_notif_channel',
//           'Daily Notifications',
//           channelDescription: 'Channel for daily reminders',
//           importance: Importance.max,
//           priority: Priority.high,
//         );

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       const NotificationDetails(android: androidDetails),
//     );
//   }

//   Future<void> scheduleDailyNotification({
//     required int hour,
//     required int minute,
//     required String title,
//     required String body,
//   }) async {
//     final androidDetails = const AndroidNotificationDetails(
//       'daily_notif_channel',
//       'Daily Notifications',
//       channelDescription: 'Daily reminder channel',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     final platformDetails = NotificationDetails(android: androidDetails);
//     final scheduledTime = _nextInstanceOfTime(hour, minute);

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       title,
//       body,
//       scheduledTime,
//       platformDetails,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }

//   tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
//     final now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       hour,
//       minute,
//     );
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }
//     return scheduledDate;
//   }
// }
// import 'dart:convert';
// import 'package:http/http.dart' as http; // ADDED
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// // Your screens
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart';

// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   tz.initializeTimeZones();
//   await NotificationService().init();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           navigatorKey: navigatorKey,
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           home: const AuthGate(),
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/journeyguide': (_) => const JourneyGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasData) {
//           return const HomeScreenWithNotifications();
//         }
//         return const WelcomeScreen();
//       },
//     );
//   }
// }

// class HomeScreenWithNotifications extends StatefulWidget {
//   const HomeScreenWithNotifications({super.key});

//   @override
//   State<HomeScreenWithNotifications> createState() =>
//       _HomeScreenWithNotificationsState();
// }

// class _HomeScreenWithNotificationsState
//     extends State<HomeScreenWithNotifications> {
//   @override
//   void initState() {
//     super.initState();
//     _requestNotificationPermission();
//   }

//   Future<void> _requestNotificationPermission() async {
//     var status = await Permission.notification.status;

//     if (!status.isGranted) {
//       final result = await Permission.notification.request();
//       if (result.isGranted) {
//         _setupNotifications();
//       }
//     } else {
//       _setupNotifications();
//     }
//   }

//   void _setupNotifications() async {
//     _showWelcomeDialog();

//     try {
//       // FETCH NOTIFICATION FROM PYTHON SERVER
//       final response = await http.get(
//         Uri.parse('http://192.168.31.94:5000/notify'),
//       );
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final title = data['title'] ?? 'Server Notification';
//         final body = data['body'] ?? 'No message';

//         NotificationService().showNotification(title: title, body: body);
//       } else {
//         NotificationService().showNotification(
//           title: 'Error',
//           body: 'Failed to fetch notification from server',
//         );
//       }
//     } catch (e) {
//       NotificationService().showNotification(
//         title: 'Error',
//         body: 'Could not connect to server',
//       );
//     }

//     // DAILY REMINDER (optional)
//     NotificationService().scheduleDailyNotification(
//       hour: 23,
//       minute: 24,
//       title: 'Daily Reminder',
//       body: 'This is your daily notification!',
//     );
//   }

//   void _showWelcomeDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Welcome!'),
//             content: const Text('Thank you for allowing notifications.'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const HomeScreen();
//   }
// }

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   NotificationService._internal();

//   Future<void> init() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   Future<void> showNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//           'daily_notif_channel',
//           'Daily Notifications',
//           channelDescription: 'Channel for daily reminders',
//           importance: Importance.max,
//           priority: Priority.high,
//         );

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       const NotificationDetails(android: androidDetails),
//     );
//   }

//   Future<void> scheduleDailyNotification({
//     required int hour,
//     required int minute,
//     required String title,
//     required String body,
//   }) async {
//     final androidDetails = const AndroidNotificationDetails(
//       'daily_notif_channel',
//       'Daily Notifications',
//       channelDescription: 'Daily reminder channel',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     final platformDetails = NotificationDetails(android: androidDetails);
//     final scheduledTime = _nextInstanceOfTime(hour, minute);

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       title,
//       body,
//       scheduledTime,
//       platformDetails,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }

//   tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
//     final now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       hour,
//       minute,
//     );
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }
//     return scheduledDate;
//   }
// }
// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';
// import 'package:permission_handler/permission_handler.dart';

// // Your screens
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart';

// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           navigatorKey: navigatorKey,
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           home: const AuthGate(),
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/journeyguide': (_) => const JourneyGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasData) {
//           return const HomeScreenWithServerMessages();
//         }
//         return const WelcomeScreen();
//       },
//     );
//   }
// }

// class HomeScreenWithServerMessages extends StatefulWidget {
//   const HomeScreenWithServerMessages({super.key});

//   @override
//   State<HomeScreenWithServerMessages> createState() =>
//       _HomeScreenWithServerMessagesState();
// }

// class _HomeScreenWithServerMessagesState
//     extends State<HomeScreenWithServerMessages> {
//   Timer? _pollingTimer;
//   final String serverUrl =
//       "http://192.168.31.94:5000/notify"; // your backend IP
//   String? latestMessage;

//   @override
//   void initState() {
//     super.initState();
//     _requestPermissionAndStart();
//   }

//   Future<void> _requestPermissionAndStart() async {
//     var status = await Permission.notification.status;
//     if (!status.isGranted) {
//       await Permission.notification.request();
//     }
//     _startPollingServer();
//   }

//   void _startPollingServer() {
//     _checkServerNotification();
//     _pollingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       _checkServerNotification();
//     });
//   }

//   Future<void> _checkServerNotification() async {
//     try {
//       final response = await http.get(Uri.parse(serverUrl));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['notify'] == true) {
//           setState(() {
//             latestMessage = "${data['title'] ?? ''}: ${data['message'] ?? ''}";
//           });
//         }
//       } else {
//         debugPrint('Server error: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error connecting to server: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           const HomeScreen(),
//           if (latestMessage != null)
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.deepPurple,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   latestMessage!,
//                   style: const TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// // }
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';

// // // Your screens
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart';

// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           navigatorKey: navigatorKey,
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           home: const AuthGate(),
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/journeyguide': (_) => const JourneyGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasData) {
//           return const HomeScreenWithServerMessage();
//         }
//         return const WelcomeScreen();
//       },
//     );
//   }
// }

// class HomeScreenWithServerMessage extends StatefulWidget {
//   const HomeScreenWithServerMessage({super.key});

//   @override
//   State<HomeScreenWithServerMessage> createState() =>
//       _HomeScreenWithServerMessageState();
// }

// class _HomeScreenWithServerMessageState
//     extends State<HomeScreenWithServerMessage> {
//   final String serverUrl =
//       "http://192.168.31.94:5000/notify"; // Replace with your backend IP
//   String? title;
//   String? body;
//   bool loading = true;
//   String? error;

//   @override
//   void initState() {
//     super.initState();
//     fetchServerMessage();
//   }

//   Future<void> fetchServerMessage() async {
//     try {
//       final response = await http.get(Uri.parse(serverUrl));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           title = data['title'] ?? 'No Title';
//           body = data['body'] ?? 'No message body';
//           loading = false;
//         });
//       } else {
//         setState(() {
//           error = 'Server error: ${response.statusCode}';
//           loading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         error = 'Failed to fetch message: $e';
//         loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:
//           loading
//               ? const Center(child: CircularProgressIndicator())
//               : error != null
//               ? Center(
//                 child: Text(error!, style: const TextStyle(color: Colors.red)),
//               )
//               : Stack(
//                 children: [
//                   const HomeScreen(),
//                   Positioned(
//                     bottom: 20,
//                     left: 20,
//                     right: 20,
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.deepPurple,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             title ?? '',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             body ?? '',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';

// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart';

// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           navigatorKey: navigatorKey,
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           home: const AuthGate(), // 👈 this decides where to go
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/journeyguide': (_) => const JourneyGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }

// /// This widget listens to Firebase auth state and routes accordingly
// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // Still loading Firebase
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         // User is logged in
//         if (snapshot.hasData) {
//           return const HomeScreen();
//         }
//         // No user logged in
//         return const WelcomeScreen();
//       },
//     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart';

// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   if (message.data['screen'] == 'chat') {
//     navigatorKey.currentState?.pushNamed('/chat');
//   }
// }

// // Future<void> setupFirebaseMessaging() async {
// //   final messaging = FirebaseMessaging.instance;

// //   // Request permissions
// //   await messaging.requestPermission(alert: true, badge: true, sound: true);

// //   // Handle background messages
// //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// //   // Handle foreground messages
// //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
// //     // You can show a local notification here if needed
// //   });

// //   // Handle notification taps when app is in background
// //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
// //     if (message.data['screen'] == 'chat') {
// //       navigatorKey.currentState?.pushNamed('/chat');
// //     }
// //   });

// //   // Get the initial message if app was terminated
// //   final initialMessage = await messaging.getInitialMessage();
// //   if (initialMessage != null && initialMessage.data['screen'] == 'chat') {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       navigatorKey.currentState?.pushNamed('/chat');
// //     });
// //   }

// //   // Subscribe to user topic after login (handled in auth flow)
// // }
// Future<void> setupFirebaseMessaging() async {
//   final messaging = FirebaseMessaging.instance;

//   // Request permissions
//   await messaging.requestPermission(alert: true, badge: true, sound: true);

//   // Handle background messages
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // Handle foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     final msg = {
//       'type': 'spiral',
//       'stage': 'inner_compass',
//       'question':
//           'Recall a time when your only focus was to make it through the day. What mattered most in that moment?',
//       'created_at': DateTime.now().millisecondsSinceEpoch,
//       'from': 'system',
//     };
//     // await _storeMessage(msg);
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser!.uid)
//         .collection('mergedMessages')
//         .add(msg);
//   });

//   // Handle notification taps when app is in background
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//     final msg = {
//       'type': 'spiral',
//       'stage': 'inner_compass',
//       'question':
//           'Recall a time when your only focus was to make it through the day. What mattered most in that moment?',
//       'created_at': DateTime.now().millisecondsSinceEpoch,
//       'from': 'system',
//     };
//     // await _storeMessage(msg);
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser!.uid)
//         .collection('mergedMessages')
//         .add(msg);
//     if (message.data['screen'] == 'chat') {
//       navigatorKey.currentState?.pushNamed('/chat');
//     }
//   });

//   // Get the initial message if app was terminated
//   final initialMessage = await messaging.getInitialMessage();
//   if (initialMessage != null) {
//     final msg = {
//       'type': 'spiral',
//       'stage': 'inner_compass',
//       'question':
//           'Recall a time when your only focus was to make it through the day. What mattered most in that moment?',
//       'created_at': DateTime.now().millisecondsSinceEpoch,
//       'from': 'system',
//     };
//     // await _storeMessage(msg);
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser!.uid)
//         .collection('mergedMessages')
//         .add(msg);
//     if (initialMessage.data['screen'] == 'chat') {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         navigatorKey.currentState?.pushNamed('/chat');
//       });
//     }
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await setupFirebaseMessaging();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           navigatorKey: navigatorKey,
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           home: const AuthGate(),
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/journeyguide': (_) => const JourneyGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   Future<void> _subscribeToUserTopic() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await FirebaseMessaging.instance.subscribeToTopic('user_${user.uid}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasData) {
//           // Subscribe to user topic when logged in
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _subscribeToUserTopic();
//           });
//           return const HomeScreen();
//         }
//         return const WelcomeScreen();
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart';

// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await _storeMessage({
//     'type': 'spiral',
//     'stage': 'inner_compass',
//     'question':
//         'Recall a time when your only focus was to make it through the day. What mattered most in that moment?',
//     'created_at': DateTime.now().millisecondsSinceEpoch,
//     'from': 'system',
//   });

//   if (message.data['screen'] == 'chat') {
//     navigatorKey.currentState?.pushNamed('/chat');
//   }
// }

// Future<void> _storeMessage(Map<String, dynamic> msg) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     debugPrint("⚠ No user logged in, cannot store message");
//     return;
//   }

//   try {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .collection('mergedMessages')
//         .add(msg);
//     debugPrint("✅ Message stored in Firestore: $msg");
//   } catch (e) {
//     debugPrint("❌ Error storing message: $e");
//   }
// }

// // Future<void> setupFirebaseMessaging() async {
// //   final messaging = FirebaseMessaging.instance;

// //   // Request permissions
// //   await messaging.requestPermission(alert: true, badge: true, sound: true);

// //   // Handle background messages
// //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// //   // Foreground messages
// //   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
// //     final msg = {
// //       'type': 'spiral',
// //       'stage': 'inner_compass',
// //       'question':
// //           'Recall a time when your only focus was to make it through the day. What mattered most in that moment?',
// //       'created_at': DateTime.now().millisecondsSinceEpoch,
// //       'from': 'system',
// //     };
// //     await _storeMessage(msg);
// //   });

// //   // When app opened from background
// //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
// //     final msg = {
// //       'type': 'spiral',
// //       'stage': 'inner_compass',
// //       'question':
// //           'Recall a time when your only focus was to make it through the day. What mattered most in that moment?',
// //       'created_at': DateTime.now().millisecondsSinceEpoch,
// //       'from': 'system',
// //     };
// //     await _storeMessage(msg);

// //     if (message.data['screen'] == 'chat') {
// //       navigatorKey.currentState?.pushNamed('/chat');
// //     }
// //   });

// //   // When app opened from terminated state
// //   final initialMessage = await messaging.getInitialMessage();
// //   if (initialMessage != null) {
// //     final msg = {
// //       'type': 'spiral',
// //       'stage': 'inner_compass',
// //       'question':
// //           'Recall a time when your only focus was to make it through the day. What mattered most in that moment?',
// //       'created_at': DateTime.now().millisecondsSinceEpoch,
// //       'from': 'system',
// //     };
// //     await _storeMessage(msg);

// //     if (initialMessage.data['screen'] == 'chat') {
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         navigatorKey.currentState?.pushNamed('/chat');
// //       });
// //     }
// //   }
// // }
// Future<void> setupFirebaseMessaging() async {
//   final messaging = FirebaseMessaging.instance;

//   // Ask for permissions
//   await messaging.requestPermission(alert: true, badge: true, sound: true);

//   // Background handler → ONLY place we store the bot message
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // Foreground messages → just navigate, no storing
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     if (message.data['screen'] == 'chat') {
//       navigatorKey.currentState?.pushNamed('/chat');
//     }
//   });

//   // App opened from background → just navigate
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//     if (message.data['screen'] == 'chat') {
//       navigatorKey.currentState?.pushNamed('/chat');
//     }
//   });

//   // App opened from terminated → just navigate
//   final initialMessage = await messaging.getInitialMessage();
//   if (initialMessage != null && initialMessage.data['screen'] == 'chat') {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       navigatorKey.currentState?.pushNamed('/chat');
//     });
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await setupFirebaseMessaging();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           navigatorKey: navigatorKey,
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           home: const AuthGate(),
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/journeyguide': (_) => const JourneyGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   Future<void> _subscribeToUserTopic() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await FirebaseMessaging.instance.subscribeToTopic('user_${user.uid}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasData) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _subscribeToUserTopic();
//           });
//           return const HomeScreen();
//         }
//         return const WelcomeScreen();
//       },
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart';

// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// /// ✅ Store ONE bot message
// // Future<void> _storeMessageOnce(RemoteMessage message) async {
// //   final user = FirebaseAuth.instance.currentUser;
// //   if (user == null) return;

// //   try {
// //     await FirebaseFirestore.instance
// //         .collection('users')
// //         .doc(user.uid)
// //         .collection('mergedMessages')
// //         .add({
// //           'type': 'spiral',
// //           'stage': 'inner_compass',
// //           'question':
// //               'Recall a time when your only focus was to make it through the day. What mattered most in that moment?',
// //           'created_at': DateTime.now().millisecondsSinceEpoch,
// //           'from': 'system',
// //         });
// //   } catch (e) {
// //     debugPrint("❌ Error storing message: $e");
// //   }
// // }
// Future<void> _storeMessageOnce(RemoteMessage message) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return;

//   final now = DateTime.now();
//   final todayStart =
//       DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

//   try {
//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('mergedMessages')
//             .where('created_at', isGreaterThanOrEqualTo: todayStart)
//             .where('from', isEqualTo: 'system')
//             .get();

//     if (snapshot.docs.isNotEmpty) {
//       debugPrint("⚠️ Bot message already exists today, skipping.");
//       return;
//     }

//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .collection('mergedMessages')
//         .add({
//           'type': 'spiral',
//           'stage': 'inner_compass',
//           'question':
//               'Recall a time when your only focus was to make it through the day. What mattered most in that moment?',
//           'created_at': DateTime.now().millisecondsSinceEpoch,
//           'from': 'system',
//         });

//     debugPrint("✅ Bot message stored once.");
//   } catch (e) {
//     debugPrint("❌ Error storing message: $e");
//   }
// }

// /// ✅ Background handler is the ONLY place that creates bot message
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await _storeMessageOnce(message);

//   if (message.data['screen'] == 'chat') {
//     navigatorKey.currentState?.pushNamed('/chat');
//   }
// }

// // Future<void> setupFirebaseMessaging() async {
// //   final messaging = FirebaseMessaging.instance;
// //   await messaging.unsubscribeFromTopic("general");
// //   await messaging.unsubscribeFromTopic("daily_task");
// //   await messaging.deleteToken();
// //   await messaging.requestPermission(alert: true, badge: true, sound: true);

// //   // Only background handler will insert bot message
// //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// //   // Foreground messages → navigate only
// //   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
// //     if (message.data['screen'] == 'chat') {
// //       navigatorKey.currentState?.pushNamed('/chat');
// //     }
// //   });

// //   // App opened from background → navigate only
// //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
// //     if (message.data['screen'] == 'chat') {
// //       navigatorKey.currentState?.pushNamed('/chat');
// //     }
// //   });

// //   // App opened from terminated → navigate only
// //   final initialMessage = await messaging.getInitialMessage();
// //   if (initialMessage != null && initialMessage.data['screen'] == 'chat') {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       navigatorKey.currentState?.pushNamed('/chat');
// //     });
// //   }
// // }
// Future<void> setupFirebaseMessaging() async {
//   final messaging = FirebaseMessaging.instance;

//   // Request permissions
//   await messaging.requestPermission(alert: true, badge: true, sound: true);

//   // Get token and subscribe to user topic
//   String? token = await messaging.getToken();
//   final user = FirebaseAuth.instance.currentUser;
//   if (user != null && token != null) {
//     await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
//       "fcmToken": token,
//     }, SetOptions(merge: true));

//     await messaging.subscribeToTopic("user_${user.uid}");
//   }

//   // Background handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // Foreground handler
//   FirebaseMessaging.onMessage.listen((message) {
//     if (message.data['screen'] == 'chat') {
//       navigatorKey.currentState?.pushNamed('/chat');
//     }
//   });

//   // App opened from background
//   FirebaseMessaging.onMessageOpenedApp.listen((message) {
//     if (message.data['screen'] == 'chat') {
//       navigatorKey.currentState?.pushNamed('/chat');
//     }
//   });

//   // Terminated app
//   final initialMessage = await messaging.getInitialMessage();
//   if (initialMessage != null && initialMessage.data['screen'] == 'chat') {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       navigatorKey.currentState?.pushNamed('/chat');
//     });
//   }

//   // Refresh token listener
//   FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
//     if (user != null) {
//       await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
//         "fcmToken": newToken,
//       }, SetOptions(merge: true));
//       await messaging.subscribeToTopic("user_${user.uid}");
//     }
//   });
// }

// Future<void> resetAllSubscriptions() async {
//   final messaging = FirebaseMessaging.instance;

//   // Option 1: delete the whole token (recommended!)
//   await messaging.deleteToken();

//   // Force get a new token
//   await messaging.getToken();
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   // await resetAllSubscriptions();
//   await setupFirebaseMessaging();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           navigatorKey: navigatorKey,
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           home: const AuthGate(),
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/journeyguide': (_) => const JourneyGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   Future<void> _subscribeToUserTopic() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await FirebaseMessaging.instance.subscribeToTopic('user_${user.uid}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasData) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _subscribeToUserTopic();
//           });
//           return const HomeScreen();
//         }
//         return const WelcomeScreen();
//       },
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/merged_reflect_screen.dart';
// import 'screens/user_guide_screen.dart';
// import 'screens/spiral_evolution_chart.dart';
// import 'screens/my_account_screen.dart';
// import 'screens/settings_screen.dart';
// import 'screens/welcome_screen.dart';
// import 'screens/journey_guide_screen.dart';

// final ValueNotifier<int> selectedBgIndex = ValueNotifier<int>(0);
// final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
//   ThemeMode.system,
// );
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Future<void> _storeMessageOnce(RemoteMessage message) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return;

//   final now = DateTime.now();
//   final todayStart =
//       DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

//   try {
//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('mergedMessages')
//             .where('created_at', isGreaterThanOrEqualTo: todayStart)
//             .where('from', isEqualTo: 'system')
//             .get();

//     if (snapshot.docs.isNotEmpty) {
//       debugPrint("⚠ Bot message already exists today, skipping.");
//       return;
//     }

//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .collection('mergedMessages')
//         .add({
//           'type': 'spiral',
//           'stage': 'inner_compass',
//           'question':
//               'Recall a time when your only focus was to make it through the day. What mattered most in that moment?',
//           'created_at': DateTime.now().millisecondsSinceEpoch,
//           'from': 'system',
//         });

//     debugPrint("✅ Bot message stored once.");
//   } catch (e) {
//     debugPrint("❌ Error storing message: $e");
//   }
// }

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await _storeMessageOnce(message);

//   if (message.data['screen'] == 'chat') {
//     navigatorKey.currentState?.pushNamed('/chat');
//   }
// }

// Future<void> setupFirebaseMessaging() async {
//   final messaging = FirebaseMessaging.instance;

//   // Request permissions
//   await messaging.requestPermission(alert: true, badge: true, sound: true);

//   // Get token and subscribe to user topic
//   String? token = await messaging.getToken();
//   final user = FirebaseAuth.instance.currentUser;
//   if (user != null && token != null) {
//     await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
//       "fcmToken": token,
//     }, SetOptions(merge: true));

//     await messaging.subscribeToTopic("user_${user.uid}");
//   }

//   // Background handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // Foreground handler
//   // FirebaseMessaging.onMessage.listen((message) async {
//   //   if (message.data['screen'] == 'chat') {
//   //     navigatorKey.currentState?.pushNamed('/chat');
//   //   }

//   //   // Also store in Firestore
//   //   if (message.notification != null) {
//   //     await _storeMessageOnce(message);
//   //   }
//   // });
//   // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//   //   if (message.data['type'] == 'daily_task') {
//   //     // Check if we've already shown this notification today
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final lastNotificationDate = prefs.getString('lastNotificationDate');
//   //     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//   //     if (lastNotificationDate != today) {
//   //       // Show notification
//   //       await prefs.setString('lastNotificationDate', today);

//   //       // Your existing notification display code
//   //     }
//   //   }
//   // });
//   // App opened from background

//   // Modify your message handler
//   // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//   //   if (message.data['type'] == 'daily_task') {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final lastTask = prefs.getString('lastDailyTask');
//   //     final currentTask = message.data['task'];

//   //     // Only show if it's a new task
//   //     if (lastTask != currentTask) {
//   //       await prefs.setString('lastDailyTask', currentTask);

//   //       // Show your notification here
//   //       // ... your existing notification display code ...
//   //     }
//   //   }
//   // });
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     if (message.data['type'] == 'daily_task') {
//       final prefs = await SharedPreferences.getInstance();
//       final lastTaskDate = prefs.getString('lastDailyTaskDate');
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//       if (lastTaskDate != today) {
//         await prefs.setString('lastDailyTaskDate', today);

//         // ✅ Show notification here
//       } else {
//         debugPrint("⚠ Already notified today, skipping.");
//       }
//     }
//   });

//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//     if (message.data['type'] == 'daily_task') {
//       // Clear the stored task when opened to allow new notifications
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('lastDailyTask');
//     }
//   });

//   FirebaseMessaging.onMessageOpenedApp.listen((message) {
//     if (message.data['screen'] == 'chat') {
//       navigatorKey.currentState?.pushNamed('/chat');
//     }
//   });

//   // Terminated app
//   final initialMessage = await messaging.getInitialMessage();
//   if (initialMessage != null && initialMessage.data['screen'] == 'chat') {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       navigatorKey.currentState?.pushNamed('/chat');
//     });
//   }

//   // Refresh token listener
//   FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
//     if (user != null) {
//       await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
//         "fcmToken": newToken,
//       }, SetOptions(merge: true));
//       await messaging.subscribeToTopic("user_${user.uid}");
//     }
//   });
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await setupFirebaseMessaging();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeModeNotifier,
//       builder: (context, mode, _) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'RETVRN',
//           navigatorKey: navigatorKey,
//           themeMode: mode,
//           theme: ThemeData(
//             brightness: Brightness.light,
//             primarySwatch: Colors.deepPurple,
//             scaffoldBackgroundColor: Colors.white,
//             useMaterial3: true,
//           ),
//           darkTheme: ThemeData(
//             brightness: Brightness.dark,
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             primaryColor: Colors.deepPurple,
//             elevatedButtonTheme: ElevatedButtonThemeData(
//               style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//             ),
//             useMaterial3: true,
//           ),
//           home: const AuthGate(),
//           routes: {
//             '/welcome': (_) => const WelcomeScreen(),
//             '/login': (_) => const LoginScreen(),
//             '/register': (_) => const RegisterScreen(),
//             '/home': (_) => const HomeScreen(),
//             '/chat': (_) => const MergedReflectScreen(),
//             '/guide': (_) => const UserGuideScreen(),
//             '/journeyguide': (_) => const JourneyGuideScreen(),
//             '/graph': (_) => const SpiralEvolutionChartScreen(),
//             '/myaccount': (_) => const MyAccountScreen(),
//             '/settings': (_) => const SettingsScreen(),
//           },
//         );
//       },
//     );
//   }
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   Future<void> _subscribeToUserTopic() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await FirebaseMessaging.instance.subscribeToTopic('user_${user.uid}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (snapshot.hasData) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _subscribeToUserTopic();
//           });
//           return const HomeScreen();
//         }
//         return const WelcomeScreen();
//       },
//     );
//   }
// }
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
