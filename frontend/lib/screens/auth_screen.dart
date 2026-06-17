import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Text('SkillSphere',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                    'Teach. Learn. Build. Exchange time credits instead of money.',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 28),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                        value: false,
                        label: Text('Login'),
                        icon: Icon(Icons.login)),
                    ButtonSegment(
                        value: true,
                        label: Text('Signup'),
                        icon: Icon(Icons.person_add_alt)),
                  ],
                  selected: {_register},
                  onSelectionChanged: (value) =>
                      setState(() => _register = value.first),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_register) ...[
                        TextFormField(
                            controller: _name,
                            enabled: !session.loading,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Name is required';
                              if (value!.length < 2) return 'Name must be at least 2 characters';
                              return null;
                            },
                            decoration: const InputDecoration(
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.badge_outlined))),
                        const SizedBox(height: 12),
                        TextFormField(
                            controller: _username,
                            enabled: !session.loading,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Username is required';
                              if (value!.length < 3) return 'Username must be at least 3 characters';
                              if (!RegExp(r'^[a-zA-Z0-9_]*$').hasMatch(value)) {
                                return 'Username can only contain letters, numbers, and underscores';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.alternate_email))),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                          controller: _email,
                          enabled: !session.loading,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Email is required';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value!)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline))),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: _password,
                          enabled: !session.loading,
                          obscureText: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Password is required';
                            if (value!.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline))),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: session.loading ? null : _submit,
                          icon: session.loading
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.arrow_forward),
                          label: Text(
                              _register ? 'Create account' : 'Enter SkillSphere'),
                        ),
                      ),
                      if (session.error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Theme.of(context).colorScheme.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(session.error!,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = context.read<SessionProvider>();
    try {
      if (_register) {
        await session.register(
            _name.text, _username.text, _email.text, _password.text);
      } else {
        await session.login(_email.text, _password.text);
      }
      if (!mounted) return;
      if (session.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_register ? 'Account created successfully!' : 'Welcome back!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${session.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
