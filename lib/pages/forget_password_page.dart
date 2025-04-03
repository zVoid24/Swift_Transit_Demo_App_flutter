import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_final/services/authentication.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ForgetPassword extends StatefulWidget {
  final AuthenticationService authService;
  const ForgetPassword({super.key, required this.authService});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showMessageDialog(String title, String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (title == "Success") {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forget Password"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? Center(
                  child: const SpinKitWaveSpinner(
                    color: Colors.black,
                    size: 50.0,
                  ),
                )
                : ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    Image.asset('assets/images/4.png', height: 200),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: "Email",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                setState(() => _isLoading = true);
                                try {
                                  await widget.authService.reset(
                                    _emailController.text,
                                  );
                                  _showMessageDialog(
                                    "Success",
                                    "Password reset email sent. Check your inbox.",
                                  );
                                } on FirebaseAuthException catch (e) {
                                  String errorMessage =
                                      e.message ?? "An error occurred.";
                                  switch (e.code) {
                                    case 'missing-email':
                                      errorMessage =
                                          "Please enter an email address.";
                                      break;
                                    case 'invalid-email':
                                      errorMessage =
                                          "The email address is not valid.";
                                      break;
                                    case 'user-not-found':
                                      errorMessage =
                                          "No user found with this email.";
                                      break;
                                  }
                                  _showMessageDialog("Error", errorMessage);
                                } catch (e) {
                                  _showMessageDialog(
                                    "Error",
                                    "Unexpected error: $e",
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _emailController.clear();
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text("Send Reset Email"),
                    ),
                  ],
                ),
      ),
    );
  }
}
