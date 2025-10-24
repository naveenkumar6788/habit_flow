import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paceai/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isRegister = false;
  bool loading = false;
  String? error;

  Future<void> _submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      if (isRegister) {
        await auth.registerEmail(emailCtrl.text.trim(), passCtrl.text.trim());
      } else {
        await auth.signInEmail(emailCtrl.text.trim(), passCtrl.text.trim());
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _google() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await context.read<AuthProvider>().signInGoogle();
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(isRegister ? 'Create account' : 'Welcome back', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passCtrl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: loading ? null : _submit,
                    child: Text(loading ? 'Please wait...' : (isRegister ? 'Sign up' : 'Sign in')),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: loading ? null : _google,
                    icon: const Icon(Icons.login, color: Colors.blue),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () => setState(() => isRegister = !isRegister),
                    child: Text(isRegister ? 'Have an account? Sign in' : 'No account? Create one'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
