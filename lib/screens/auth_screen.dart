import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // We'll use this to toggle between Login and Signup
  bool _isLogin = true; // true for Login, false for Signup

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // For the Tenant/Landlord toggle on Signup
  bool _isTenant = true; // true for Tenant, false for Landlord

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Allows the content to scroll if it exceeds screen height
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
          children: [
            // App Logo/Name
            Center(
              child: Text(
                'Project App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Login/Signup Toggle Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLogin ? Theme.of(context).primaryColor : Colors.grey[200],
                    foregroundColor: _isLogin ? Colors.white : Colors.black,
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isLogin ? Theme.of(context).primaryColor : Colors.grey[200],
                    foregroundColor: !_isLogin ? Colors.white : Colors.black,
                  ),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Conditional rendering based on _isLogin
            _isLogin ? _buildLoginForm(context) : _buildSignupForm(context),

            // Social Login Buttons (for both Login and Signup)
            const SizedBox(height: 30),
            const Center(child: Text('OR')),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement Login/Signup with Google
                print('Login with Google');
              },
              icon: Image.asset('assets/google_logo.png', height: 24.0), // Placeholder for Google logo
              label: const Text('Login with Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement Login/Signup with Apple
                print('Login with Apple');
              },
              icon: Icon(Icons.apple, color: Colors.black, size: 28), // Apple icon
              label: const Text('Login with Apple'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email/Phone',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.person),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: const Icon(Icons.visibility_off), // Toggle visibility
          ),
          obscureText: true, // Hide password
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Navigate to Forgot Password screen
              print('Forgot Password?');
            },
            child: const Text('Forgot Password?'),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement Login logic
              print('Login button pressed');
              print('Email: ${_emailController.text}');
              print('Password: ${_passwordController.text}');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Login', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    return Column(
      children: [
        // Tenant/Landlord Toggle
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('I am a Tenant'),
                value: true,
                groupValue: _isTenant,
                onChanged: (bool? value) {
                  setState(() {
                    _isTenant = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('I am a Landlord'),
                value: false,
                groupValue: _isTenant,
                onChanged: (bool? value) {
                  setState(() {
                    _isTenant = value!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email/Phone',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.person),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: const Icon(Icons.visibility_off),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: const Icon(Icons.visibility_off),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement Signup logic
              print('Sign Up button pressed');
              print('User Type: ${_isTenant ? "Tenant" : "Landlord"}');
              print('Email: ${_emailController.text}');
              print('Password: ${_passwordController.text}');
              print('Confirm Password: ${_confirmPasswordController.text}');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 20),
        // Terms & Conditions and Privacy Policy links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Navigate to Terms & Conditions
                print('Terms & Conditions');
              },
              child: const Text('Terms & Conditions'),
            ),
            const Text(' | '),
            TextButton(
              onPressed: () {
                // TODO: Navigate to Privacy Policy
                print('Privacy Policy');
              },
              child: const Text('Privacy Policy'),
            ),
          ],
        ),
      ],
    );
  }
}
