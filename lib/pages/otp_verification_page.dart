import 'package:firebase_flutter_final/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final AuthenticationService authService;
  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.authService,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP Verification"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Pinput(
            length: 6,
            textInputAction: TextInputAction.done,
            onCompleted: (String pin) async {
              try {
                await widget.authService.verifyOtp(widget.verificationId, pin);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Invalid OTP"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
