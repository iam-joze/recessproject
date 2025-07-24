import 'package:flutter/material.dart';
// Will add Firebase imports later

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber; // Optional: to display to the user

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // We'll implement OTP verification logic here in the next step
  void _verifyOtp() {
    // Placeholder for OTP verification
    print('Verifying OTP: ${_otpController.text}');
    print('Verification ID: ${widget.verificationId}');
    // This is where Firebase signInWithCredential will go
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP verification logic coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter the 6-digit code sent to ${widget.phoneNumber}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6, // OTPs are typically 6 digits
              decoration: const InputDecoration(
                hintText: '------',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _verifyOtp,
              child: const Text('Verify Code'),
            ),
            // Optional: Resend Code button
            TextButton(
              onPressed: () {
                // Implement resend logic here (requires _verificationId and _resendToken)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resend code logic coming soon!')),
                );
              },
              child: const Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}