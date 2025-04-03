import 'package:firebase_flutter_final/services/sslcommerz.dart';
import 'package:firebase_flutter_final/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class Recharge extends StatefulWidget {
  const Recharge({super.key});

  @override
  State<Recharge> createState() => _RechargeState();
}

class _RechargeState extends State<Recharge> {
  bool _isLoading = false;
  final TextEditingController _rechargeAmount = TextEditingController();

  Future<bool> _handleRecharge() async {
    double? amount = double.tryParse(_rechargeAmount.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }

    // Create SSLCommerzService object and call payment
    SSLCommerzService paymentService = SSLCommerzService(amount: amount);
    bool success = await paymentService.initiatePayment();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Successful!"),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Failed!"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
          child: SpinKitWaveSpinner(color: Colors.black, size: 50.0),
        )
        : Scaffold(
          appBar: AppBar(
            title: const Text(
              "Recharge",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ListView(
                children: [
                  Image.asset(
                    "assets/images/undraw_credit-card_t6qm.png",
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _rechargeAmount,
                    decoration: const InputDecoration(
                      labelText: "Enter Amount",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      final success = await _handleRecharge();
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                        _rechargeAmount.clear();
                        if (success) Get.offAll(() => Wrapper());
                      }
                    },
                    child: const Text("Recharge"),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
