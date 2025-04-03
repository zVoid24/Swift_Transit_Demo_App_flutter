import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_final/services/database.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

class SSLCommerzService {
  final double amount;

  SSLCommerzService({required this.amount});

  Future<bool> initiatePayment() async {
    if (amount <= 0) {
      return false; // Invalid amount
    }

    final sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        multi_card_name: "visa,master,bkash",
        currency: SSLCurrencyType.BDT,
        product_category: "Recharge",
        sdkType: SSLCSdkType.TESTBOX, // Change to LIVE for production
        store_id: "swift67e6da772fed6",
        store_passwd: "swift67e6da772fed6@ssl",
        total_amount: amount,
        tran_id: "TXN_${DateTime.now().millisecondsSinceEpoch}",
      ),
    );

    try {
      var result = await sslcommerz.payNow();
      if (result.status == "VALID") {
        // Payment successful, update user balance
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          Database db = Database(uid: userId);
          await db.updateBalance(amount);
          await db.updateTransaction(Timestamp.now(), amount, "Recharge");
        }
        return true; // Payment success
      }
      return false; // Payment failed
    } catch (e) {
      return false; // Error occurred
    }
  }
}
