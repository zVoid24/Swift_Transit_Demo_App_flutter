import 'package:flutter/material.dart';
import 'package:firebase_flutter_final/services/authentication.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PhoneLogin extends StatefulWidget {
  final AuthenticationService authService;
  const PhoneLogin({super.key, required this.authService});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
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
        title: const Text("Phone Login"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefixText: "+880",
                        icon: Icon(Icons.phone),
                        labelText: "Phone Number",
                        hintText: "Enter your phone number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  // Assuming sendCode is in AuthenticationService or another file
                                  await widget.authService.sendCode(
                                    _phoneController.text,
                                  );
                                  // If sendCode handles navigation, no need to navigate here
                                } catch (e) {
                                  _showErrorDialog("Error: $e");
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text("Send OTP"),
                    ),
                  ],
                ),
      ),
    );
  }
}
