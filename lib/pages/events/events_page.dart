import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:paceai/providers/events_provider.dart';
import 'package:paceai/pages/events/event_editor_page.dart';
import 'package:paceai/providers/auth_provider.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    final userId = context.watch<AuthProvider>().userId;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Community Events', style: Theme.of(context).textTheme.headlineMedium),
              FilledButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventEditorPage()));
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('New Event'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final e in provider.events)
            Card(
              child: ListTile(
                title: Text(e.title),
                subtitle: Text('${DateFormat.yMMMd().add_jm().format(e.dateTime.toLocal())}\n${e.description}'),
                isThreeLine: true,
                trailing: FilledButton(
                  onPressed: () => provider.toggleRsvp(e.id),
                  child: Text((userId != null && e.rsvps.contains(userId)) ? 'Cancel' : 'RSVP'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
