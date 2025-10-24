import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paceai/providers/notifications_provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Notifications', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          for (final n in provider.notifications)
            Card(
              child: ListTile(
                title: Text(n.message),
                subtitle: Text(n.type),
                trailing: n.read
                    ? const Icon(Icons.check, color: Colors.green)
                    : TextButton(
                        onPressed: () => provider.markRead(n.id),
                        child: const Text('Mark read'),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
