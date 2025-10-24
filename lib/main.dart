import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:paceai/firebase_options.dart';
import 'package:paceai/theme.dart';
import 'package:paceai/pages/auth/auth_gate.dart';
import 'package:paceai/providers/auth_provider.dart';
import 'package:paceai/providers/habits_provider.dart';
import 'package:paceai/providers/feed_provider.dart';
import 'package:paceai/providers/events_provider.dart';
import 'package:paceai/providers/gamification_provider.dart';
import 'package:paceai/providers/notifications_provider.dart';
import 'package:paceai/services/messaging_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, HabitsProvider>(
          create: (_) => HabitsProvider(),
          update: (_, auth, habits) => habits!..setUserId(auth.userId),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FeedProvider>(
          create: (_) => FeedProvider(),
          update: (_, auth, feed) => feed!..setUserId(auth.userId),
        ),
        ChangeNotifierProxyProvider<AuthProvider, EventsProvider>(
          create: (_) => EventsProvider(),
          update: (_, auth, events) => events!..setUserId(auth.userId),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GamificationProvider>(
          create: (_) => GamificationProvider(),
          update: (_, auth, game) => game!..setUserId(auth.userId),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationsProvider>(
          create: (_) => NotificationsProvider(),
          update: (_, auth, notif) => notif!..setUserId(auth.userId),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Initialize FCM after auth is ready
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final auth = context.read<AuthProvider>();
            if (auth.userId != null) {
              MessagingService.ensureInitializedAndRegisterToken(auth.userId!);
            }
          });

          return MaterialApp(
            title: 'Habitflow',
            debugShowCheckedModeBanner: false,
            theme: lightTheme.copyWith(
              textTheme: GoogleFonts.interTextTheme(lightTheme.textTheme),
            ),
            darkTheme: darkTheme.copyWith(
              textTheme: GoogleFonts.interTextTheme(darkTheme.textTheme),
            ),
            themeMode: ThemeMode.system,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
