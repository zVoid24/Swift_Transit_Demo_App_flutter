import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_final/pages/recharge_page.dart';
import 'package:firebase_flutter_final/pages/transactions_page.dart';
import 'package:firebase_flutter_final/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_final/services/authentication.dart';
import 'package:firebase_flutter_final/services/database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class Home extends StatefulWidget {
  final AuthenticationService authService;
  const Home({super.key, required this.authService});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoggingOut = false;
  bool _isLoading = false;
  late Database database; // Removed 'final' keyword
  late Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    final uid = widget.authService.user?.uid ?? '';
    database = Database(uid: uid);
    _userStream = database.userStream;
  }

  Future<void> _refreshHome() async {
    try {
      setState(() {
        _isLoading = true;
        final uid = widget.authService.user?.uid ?? '';
        database = Database(
          uid: uid,
        ); // This is now allowed since 'database' isn't final
        _userStream = database.userStream;
      });
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        _isLoading = false;
      });
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
          "Home",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context),
      body: LiquidPullToRefresh(
        onRefresh: _refreshHome,
        color: Colors.black,
        backgroundColor: Colors.white,
        height: 100,
        animSpeedFactor: 2,
        showChildOpacityTransition: false,
        child: StreamBuilder<DocumentSnapshot>(
          stream: _userStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading user data"));
            }

            if (snapshot.connectionState == ConnectionState.waiting ||
                _isLoading) {
              return Center(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 30,
                          right: 20,
                          left: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(179, 214, 212, 212),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 300,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    235,
                                    233,
                                    233,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text(
                                    'Balance: ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 100,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        235,
                                        233,
                                        233,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text(
                                    'Account Type: ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Container(
                                    width: 100,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        235,
                                        233,
                                        233,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No user logged in or data not found",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final name = data['name'] ?? "User";
            final balance = data['balance']?.toString() ?? "0.0";
            final accountType = data['student'] == true ? 'Student' : 'Regular';

            return _isLoggingOut
                ? const Center(
                  child: SpinKitThreeInOut(color: Colors.black, size: 50.0),
                )
                : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 30,
                          right: 20,
                          left: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(179, 214, 212, 212),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text(
                                    'Balance: ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '$balance BDT',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text(
                                    'Account Type: ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    accountType,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
          },
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title: const Text('Transactions'),
            leading: const Icon(Icons.currency_exchange),
            onTap: () {
              Navigator.pop(context);
              final uid = widget.authService.user?.uid ?? '';
              if (uid.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionsPage(uid: uid),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No user logged in")),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Recharge'),
            leading: const Icon(Icons.monetization_on),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Recharge()),
              );
            },
          ),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              Navigator.pop(context);
              setState(() => _isLoggingOut = true);
              try {
                await widget.authService.signOut();
                if (mounted) {
                  Get.offAll(() => const Wrapper());
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoggingOut = false);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
