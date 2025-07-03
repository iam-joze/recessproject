import 'package:flutter/material.dart';
import 'tenant_home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoggingIn = true; // toggle between login/register

  void _submit() {
    // Here you would normally validate and authenticate
    // For demo, just navigate to TenantHomeScreen
    Navigator.of(context).pushReplacement(
     MaterialPageRoute(builder: (_) => const TenantHomeScreen()),
    );
  }

  void _toggleMode() {
    setState(() {
      _isLoggingIn = !_isLoggingIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLoggingIn ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isLoggingIn ? 'Login' : 'Register'),
            ),
            TextButton(
              onPressed: _toggleMode,
              child: Text(_isLoggingIn ? 'Create an account' : 'Have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
