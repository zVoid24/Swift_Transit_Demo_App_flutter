import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_final/services/database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class TransactionsPage extends StatefulWidget {
  final String uid;

  const TransactionsPage({super.key, required this.uid});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late final Database database;
  late Stream<QuerySnapshot> _transactionStream;

  @override
  void initState() {
    super.initState();
    database = Database(uid: widget.uid);
    _transactionStream = database.transactionStream;
  }

  Future<void> _refreshTransactions() async {
    try {
      // Force a refresh by creating a new stream
      setState(() {
        _transactionStream = database.transactionStream;
      });
      // Wait for a minimum time to show the refresh animation
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error refreshing: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Transactions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Static image portion
          Image.asset(
            'assets/images/undraw_plain-credit-card_rzku.png',
            height: 200,
            fit: BoxFit.cover,
          ),
          // Refreshable transactions portion
          Expanded(
            child: LiquidPullToRefresh(
              showChildOpacityTransition: true,
              onRefresh: _refreshTransactions,
              color: Colors.black,
              backgroundColor: Colors.white,
              child: StreamBuilder<QuerySnapshot>(
                stream: _transactionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error loading transactions"),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SpinKitWaveSpinner(
                        color: Colors.black,
                        size: 50.0,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Center(
                        child: Text(
                          "No transactions found",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }

                  final transactions = snapshot.data!.docs;

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10.0),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction =
                          transactions[index].data() as Map<String, dynamic>;
                      final name = transaction['type'] ?? 'Unknown';
                      final amount = transaction['amount']?.toString() ?? '0.0';
                      final time = (transaction['time'] as Timestamp?)
                          ?.toDate()
                          .toString()
                          .substring(0, 16);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Date: $time',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Text(
                            '$amount BDT',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  amount.startsWith('-')
                                      ? Colors.red
                                      : Colors.green,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
