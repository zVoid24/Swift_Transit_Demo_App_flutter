import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final String uid; // Immutable user ID
  double balance = 0.0;

  Database({required this.uid});

  // Reference to the 'users' collection
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');

  // Reference to the 'transactions' subcollection for a specific user
  CollectionReference get transactionCollection =>
      userCollection.doc(uid).collection('transactions');

  // Create a new user document
  Future<void> createUser(String name, String email, bool isStudent) async {
    try {
      await userCollection.doc(uid).set({
        'name': name,
        'email': email,
        'balance': balance,
        'student': isStudent,
      });
    } catch (e) {
      throw Exception("Failed to create user: $e");
    }
  }

  // Update the user's balance
  Future<void> updateBalance(double amount) async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();

      if (!userDoc.exists) {
        throw Exception("User not found!");
      }

      double currentBalance = (userDoc['balance'] ?? 0.0).toDouble();
      double newBalance = currentBalance + amount;

      await userCollection.doc(uid).update({'balance': newBalance});
    } catch (e) {
      throw Exception("Failed to update balance: $e");
    }
  }

  // Add a transaction to the user's transactions subcollection
  Future<void> updateTransaction(
    Timestamp time,
    double amount,
    String type,
  ) async {
    try {
      await transactionCollection.add({
        'time': time,
        'amount': amount,
        'type': type,
      });
    } catch (e) {
      throw Exception("Failed to add transaction: $e");
    }
  }

  // Stream of user data, handling no-user case
  Stream<DocumentSnapshot> get userStream {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      // Return an empty stream if no user is logged in
      return Stream.empty();
    }
    return userCollection.doc(currentUid).snapshots();
  }

  // Optional: Stream of transactions for the user (useful for displaying them)
  Stream<QuerySnapshot> get transactionStream {
    return transactionCollection
        .orderBy('time', descending: true) // Sort by time, newest first
        .snapshots();
  }
}
