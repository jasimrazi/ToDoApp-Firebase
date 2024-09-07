import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotask/viewmodels/auth_view_model.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Enter your email address to reset your password",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 20),
                if (authViewModel.isLoading) const CircularProgressIndicator(),
                ElevatedButton(
                  onPressed: () async {
                    bool success = await authViewModel.resetPassword(
                      _emailController.text.trim(),
                    );
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Password reset email sent')),
                      );
                      Navigator.pop(context); // Go back to login screen
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Error resetting password')),
                      );
                    }
                  },
                  child: const Text('Send Reset Email'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
