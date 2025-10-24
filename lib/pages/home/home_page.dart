import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paceai/pages/habits/habits_page.dart';
import 'package:paceai/pages/feed/feed_page.dart';
import 'package:paceai/pages/events/events_page.dart';
import 'package:paceai/pages/notifications/notifications_page.dart';
import 'package:paceai/pages/profile/profile_page.dart';
import 'package:paceai/providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final pages = const [
    HabitsPage(),
    FeedPage(),
    EventsPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().profile;
    return Scaffold(
      appBar: AppBar(
        title: Text('Lifestyle & Engagement${user?.displayName != null ? ' – ${user!.displayName!}' : ''}'),
      ),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.check_circle_outline, color: Colors.blue), label: 'Habits'),
          NavigationDestination(icon: Icon(Icons.forum_outlined, color: Colors.green), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.event_outlined, color: Colors.orange), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined, color: Colors.red), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline, color: Colors.purple), label: 'Profile'),
        ],
      ),
    );
  }
}
