import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paceai/providers/auth_provider.dart';
import 'package:paceai/providers/habits_provider.dart';
import 'package:paceai/providers/feed_provider.dart';
import 'package:paceai/providers/events_provider.dart';
import 'package:paceai/pages/habits/habit_editor_page.dart';
import 'package:paceai/pages/events/event_editor_page.dart';
import 'package:paceai/pages/profile/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final postCtrl = TextEditingController();
  bool _notifEnabled = true;
  bool _privateAccount = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final habits = context.watch<HabitsProvider>().habits;
    final feedProvider = context.watch<FeedProvider>();
    final posts = feedProvider.posts;
    final commentsMap = feedProvider.comments;
    final events = context.watch<EventsProvider>().events;

    final userId = auth.userId;
    final myPosts = userId == null ? const [] : posts.where((p) => p.userId == userId).toList();
    final myEvents = userId == null ? const [] : events.where((e) => e.createdBy == userId).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.blue.withValues(alpha: 0.2),
                  backgroundImage: (auth.profile?.photoUrl != null && auth.profile!.photoUrl!.isNotEmpty)
                      ? NetworkImage(auth.profile!.photoUrl!)
                      : null,
                  child: (auth.profile?.photoUrl == null || auth.profile!.photoUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.blue, size: 36)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  auth.profile?.displayName ?? 'Naveen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (auth.profile?.email != null)
                  Text(
                    auth.profile!.email!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Habits card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Habits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HabitEditorPage()),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.blue),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  if (habits.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No habits yet. Add your first habit.'),
                    )
                  else
                    ...habits.take(5).map(
                      (h) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(h.title),
                        subtitle: h.description != null ? Text(h.description!) : null,
                        trailing: const Icon(Icons.check_circle_outline, color: Colors.blue),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Posts card with quick-add
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Posts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox.shrink(),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: postCtrl,
                          decoration: const InputDecoration(hintText: 'Share something...'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () async {
                          final text = postCtrl.text.trim();
                          if (text.isEmpty) return;
                          try {
                            await context.read<FeedProvider>().createPost(text);
                            postCtrl.clear();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Post published')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to post: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text('Post'),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (myPosts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No posts yet.'),
                    )
                  else
                    ...myPosts.take(5).map(
                      (p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(p.content),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.createdAt.toLocal().toString()),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.favorite, color: Colors.red, size: 16),
                                const SizedBox(width: 4),
                                Text('${p.likes.length}'),
                                const SizedBox(width: 12),
                                const Icon(Icons.mode_comment_outlined, color: Colors.blue, size: 16),
                                const SizedBox(width: 4),
                                Text('${(commentsMap[p.id]?.length ?? 0)}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Events card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EventEditorPage()),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.orange),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  if (myEvents.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('No events created yet.'),
                    )
                  else
                    ...myEvents.take(5).map(
                      (e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(e.title),
                        subtitle: Text('${e.dateTime.toLocal()} · ${e.description}'),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Quick settings
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.grey),
                    title: const Text('Edit Profile & App Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                  const Divider(height: 0),
                  SwitchListTile(
                    value: _notifEnabled,
                    onChanged: (v) => setState(() => _notifEnabled = v),
                    secondary: const Icon(Icons.notifications_active, color: Colors.red),
                    title: const Text('Push notifications'),
                    subtitle: const Text('Receive alerts for comments and reminders'),
                  ),
                  SwitchListTile(
                    value: _privateAccount,
                    onChanged: (v) => setState(() => _privateAccount = v),
                    secondary: const Icon(Icons.lock_outline, color: Colors.purple),
                    title: const Text('Private account'),
                    subtitle: const Text('Hide your activities from public feed'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: auth.userId == null ? null : () => auth.signOut(),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
