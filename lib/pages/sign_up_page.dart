import 'package:firebase_flutter_final/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_final/services/authentication.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SignUP extends StatefulWidget {
  final AuthenticationService authService;
  const SignUP({super.key, required this.authService});

  @override
  State<SignUP> createState() => _SignUPState();
}

class _SignUPState extends State<SignUP> {
  bool _isLoading = false; // Track loading state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isPasswordObscured = true; // Track password visibility

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
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

  List<bool> isSelected = [true, false];
  bool isStudent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
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
                      Image.asset('assets/images/5.png', height: 200),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: "Name",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: const OutlineInputBorder(),
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Sign Up as:"),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ToggleButtons(
                              isSelected: isSelected,
                              onPressed: (index) {
                                setState(() {
                                  isSelected[index] = true;
                                  isSelected[1 - index] = false;
                                  isStudent = index == 1;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Regular"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Student"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() => _isLoading = true);

                          try {
                            await widget.authService.signUp(
                              _emailController.text,
                              _passwordController.text,
                              _nameController.text,
                              isStudent,
                            );
                            await Future.delayed(Duration(seconds: 1));
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Wrapper(),
                              ),
                            );
                          } catch (e) {
                            _showErrorDialog(
                              "An error occurred. Please try again.",
                            );
                          }

                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        },
                        child: const Text("Sign Up"),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Already have an account? Sign in"),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
