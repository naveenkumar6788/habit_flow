import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paceai/providers/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkMode = false;
  final _nameCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final auth = context.read<AuthProvider>();
    _nameCtrl.text = auth.profile?.displayName ?? '';
    _initialized = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile info and editing
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: auth.profile?.email ?? '',
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.teal),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: auth.userId == null
                          ? null
                          : () async {
                              final name = _nameCtrl.text.trim();
                              if (name.isEmpty) return;
                              try {
                                await context.read<AuthProvider>().updateDisplayName(name);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Profile updated')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to update: $e')),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Save'),
                    ),
                  )
                ],
              ),
            ),
          ),
          SwitchListTile(
            value: notificationsEnabled,
            onChanged: (v) => setState(() => notificationsEnabled = v),
            secondary: const Icon(Icons.notifications, color: Colors.red),
            title: const Text('Push notifications'),
            subtitle: const Text('Receive alerts and updates'),
          ),
          SwitchListTile(
            value: darkMode,
            onChanged: (v) => setState(() => darkMode = v),
            secondary: const Icon(Icons.dark_mode, color: Colors.purple),
            title: const Text('Dark mode'),
            subtitle: const Text('Follow system theme by default'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: const Text('About'),
            subtitle: const Text('Habitflow'),
          ),
        ],
      ),
    );
  }
}
