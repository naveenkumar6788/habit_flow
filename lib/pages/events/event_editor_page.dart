import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paceai/providers/events_provider.dart';

class EventEditorPage extends StatefulWidget {
  const EventEditorPage({super.key});

  @override
  State<EventEditorPage> createState() => _EventEditorPageState();
}

class _EventEditorPageState extends State<EventEditorPage> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  DateTime dateTime = DateTime.now().add(const Duration(days: 1));
  bool saving = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Date: ${dateTime.toLocal()}')),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dateTime,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dateTime));
                      if (time != null) {
                        setState(() {
                          dateTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.calendar_today, color: Colors.orange),
                  label: const Text('Pick Date & Time'),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            FilledButton.icon(
              onPressed: saving
                  ? null
                  : () async {
                      final title = titleCtrl.text.trim();
                      final desc = descCtrl.text.trim();
                      if (title.isEmpty) {
                        setState(() => error = 'Please enter a title');
                        return;
                      }
                      setState(() {
                        saving = true;
                        error = null;
                      });
                      try {
                        await context.read<EventsProvider>().createEvent(
                              title,
                              desc,
                              dateTime,
                            );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event saved')));
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() => error = 'Failed to save: $e');
                        }
                      } finally {
                        if (mounted) setState(() => saving = false);
                      }
                    },
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(saving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
