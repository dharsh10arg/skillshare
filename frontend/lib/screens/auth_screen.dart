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
  final _name = TextEditingController(text: 'Maya Chen');
  final _username = TextEditingController(text: 'maya_demo');
  final _email = TextEditingController(text: 'maya@skillsphere.local');
  final _password = TextEditingController(text: 'Password123!');
  bool _register = false;

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
                            decoration: const InputDecoration(
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.badge_outlined))),
                        const SizedBox(height: 12),
                        TextFormField(
                            controller: _username,
                            decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.alternate_email))),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline))),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline))),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: session.loading ? null : _submit,
                        icon: session.loading
                            ? const SizedBox.square(
                                dimension: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.arrow_forward),
                        label: Text(
                            _register ? 'Create account' : 'Enter SkillSphere'),
                      ),
                      if (session.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(session.error!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
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
    if (_register) {
      await session.register(
          _name.text, _username.text, _email.text, _password.text);
    } else {
      await session.login(_email.text, _password.text);
    }
  }
}
