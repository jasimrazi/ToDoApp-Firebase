import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotask/viewmodels/auth_view_model.dart';
import 'package:todotask/views/Auth/forget_password_screen.dart';
import 'package:todotask/views/home_screen.dart';
import 'package:todotask/views/Auth/registration_page.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                if (authViewModel.isLoading) const CircularProgressIndicator(),
                ElevatedButton(
                  onPressed: () async {
                    bool success = await authViewModel.login(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    if (success) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    }
                  },
                  child: const Text('Login'),
                ),
                if (authViewModel.errorMessage != null)
                  Text(authViewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationScreen()),
                    );
                  },
                  child: const Text("Don't have an account? Register"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
