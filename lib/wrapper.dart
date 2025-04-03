import 'package:firebase_flutter_final/pages/verify_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_final/pages/home_page.dart';
import 'package:firebase_flutter_final/pages/login_page.dart';
import 'package:firebase_flutter_final/services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final AuthenticationService _authService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        User? user = snapshot.data;
        print(
          "User: ${user?.uid}, Email: ${user?.email}, Verified: ${user?.emailVerified}",
        );

        if (user == null || user.email == null) {
          print("No valid user (null or no email), navigating to LoginPage");
          return LoginPage(authService: _authService);
        } else if (!user.emailVerified) {
          print("User ${user.uid} is not verified, navigating to Verify");
          return Verify(authService: _authService);
        } else {
          print("User ${user.uid} is verified, navigating to Home");
          return Home(authService: _authService);
        }
      },
    );
  }
}
