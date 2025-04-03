import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_final/pages/forget_password_page.dart';
import 'package:firebase_flutter_final/pages/phone_login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_final/services/authentication.dart';
import 'sign_up_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPage extends StatefulWidget {
  final AuthenticationService authService;
  const LoginPage({super.key, required this.authService});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder:
            (BuildContext context) => AlertDialog(
              title: const Text("Login Failed"),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
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
        title: const Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child:
              _isLoading
                  ? SpinKitWaveSpinner(color: Colors.black, size: 50.0)
                  : ListView(
                    children: [
                      Image.asset('assets/images/1.png', height: 200),
                      SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordObscured = !_isPasswordObscured;
                              });
                            },
                            icon: Icon(
                              _isPasswordObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        obscureText: _isPasswordObscured,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ForgetPassword(
                                      authService: widget.authService,
                                    ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          try {
                            await widget.authService.signInWithEmail(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                            // Navigation handled by Wrapper
                          } on FirebaseAuthException catch (e) {
                            String errorMessage =
                                e.message ?? "An error occurred.";
                            switch (e.code) {
                              case 'user-not-found':
                                errorMessage = 'No user found with this email.';
                                break;
                              case 'wrong-password':
                                errorMessage = 'Incorrect password.';
                                break;
                              case 'invalid-email':
                                errorMessage = 'Invalid email format.';
                                break;
                            }
                            _showErrorDialog(errorMessage);
                          } catch (e) {
                            _showErrorDialog('Unexpected error: $e');
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        child: const Text("Sign in"),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      SignUP(authService: widget.authService),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[900],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Sign up"),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(Icons.g_mobiledata_outlined),
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          try {
                            User? user =
                                await widget.authService.signInWithGoogle();
                            if (user == null) {
                              _showErrorDialog('Google Sign-In was canceled.');
                            }
                            // Navigation handled by Wrapper
                          } on FirebaseAuthException catch (e) {
                            String errorMessage =
                                e.message ?? "An error occurred.";
                            switch (e.code) {
                              case 'account-exists-with-different-credential':
                                errorMessage =
                                    'This account is linked to another sign-in method.';
                                break;
                              case 'invalid-credential':
                                errorMessage = 'Invalid Google credentials.';
                                break;
                            }
                            _showErrorDialog(errorMessage);
                          } catch (e) {
                            _showErrorDialog('Unexpected error: $e');
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        label: Text("Sign in with Google"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PhoneLogin(
                                    authService: widget.authService,
                                  ),
                            ),
                          );
                        },
                        child: Text("Sign in with Phone"),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

//keytool -list -v -keystore C:\Users\Zahidul\.android\debug.keystore -alias androiddebugkey
//FF:C6:6F:A7:D2:F2:58:E8:DC:C4:EC:E5:6D:C9:1D:F5:9D:FD:F4:68
