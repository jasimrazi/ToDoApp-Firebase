import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todotask/viewmodels/auth_view_model.dart';
import 'package:todotask/views/Auth/login_screen.dart';
import 'package:todotask/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Check if the user is logged in
        final bool isLoggedIn = authViewModel.user != null;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: isLoggedIn ? HomeScreen() : LoginScreen(),
          // You can also define other properties here if needed
        );
      },
    );
  }
}
