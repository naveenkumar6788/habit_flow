import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paceai/providers/habits_provider.dart';

class HabitEditorPage extends StatefulWidget {
  const HabitEditorPage({super.key});

  @override
  State<HabitEditorPage> createState() => _HabitEditorPageState();
}

class _HabitEditorPageState extends State<HabitEditorPage> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  bool saving = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
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
                      if (title.isEmpty) {
                        setState(() => error = 'Please enter a title');
                        return;
                      }
                      setState(() {
                        saving = true;
                        error = null;
                      });
                      try {
                        await context
                            .read<HabitsProvider>()
                            .addHabit(title, descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim());
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit saved')));
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
