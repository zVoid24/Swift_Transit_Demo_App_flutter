import 'package:firebase_flutter_final/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_final/services/authentication.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class Verify extends StatefulWidget {
  final AuthenticationService authService;
  const Verify({super.key, required this.authService});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sendVerificationMail();
    });
  }

  Future<void> sendVerificationMail() async {
    final user = widget.authService.user;
    if (user == null || user.email == null) {
      Get.offAll(() => Wrapper()); // Reset navigation if user is null
      return;
    }
    try {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Verification email sent"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send verification: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void reload() async {
    setState(() => isLoading = true);
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;

      // Check if the user is still logged in
      if (user == null) {
        Get.offAll(() => Wrapper());
        return;
      }

      await user.reload(); // Reload user data

      final updatedUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (updatedUser == null) {
        Get.offAll(() => Wrapper());
        return;
      }
      if (updatedUser.emailVerified) {
        Get.offAll(() => Wrapper());
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email not verified yet"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child:
              isLoading
                  ? const SpinKitWaveSpinner(color: Colors.black, size: 50.0)
                  : ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      Image.asset(
                        'assets/images/undraw_secure-login_m11a.png',
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      const Text("Please verify your email address"),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isLoading ? null : reload,
                        child: const Text("Reload"),
                      ),
                      ElevatedButton(
                        onPressed: isLoading ? null : sendVerificationMail,
                        child: const Text("Resend Verification Email"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() => isLoading = true);
                          await widget.authService.signOut();
                          if (mounted) setState(() => isLoading = false);
                          Get.offAll(() => Wrapper());
                        },
                        child: const Text("Sign Out"),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
