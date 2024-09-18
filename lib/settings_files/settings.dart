import 'package:econowise/login_files/login.dart';
import 'package:econowise/navigation_bar.dart';
import 'package:econowise/save_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:econowise/transaction_files/transaction.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          leading: IconButton(
              onPressed: () {
                Back(context);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: () {
                logoutUser(context);
              },
              child: const Text("Log Out")),
        ));
  }
}

Future<void> logoutUser(BuildContext context) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();

    context.read<SaveData>().transactions.clear();
    context.read<SaveData>().budgets.clear();

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()));
  } catch (e) {
    print("Error during logout: $e");
  }
}

void Back(context) {
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MenuSelecter(index: 1)));
}
