import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotask/viewmodels/auth_view_model.dart';
import 'package:todotask/views/home_screen.dart';
import 'login_screen.dart';
import 'package:todotask/widgets/elevatedbutton_widget.dart';
import 'package:todotask/widgets/textfield_widget.dart';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CustomTextField(
                  controller: _fullNameController,
                  hintText: 'Full Name',
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                if (authViewModel.isLoading) const CircularProgressIndicator(),
                CustomElevatedButton(
                  text: 'REGISTER',
                  onPressed: () async {
                    if (_passwordController.text !=
                        _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords do not match')),
                      );
                      return;
                    }

                    bool success = await authViewModel.register(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );

                    if (success) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registration failed')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
