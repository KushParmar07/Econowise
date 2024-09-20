import 'package:econowise/navigation_bar.dart';
import 'package:econowise/save_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:econowise/firebase_options.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: FutureBuilder<UserCredential?>(
          // Use FutureBuilder here
          future:
              signInWithGoogle(), // Trigger sign-in when the button is pressed
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while signing in
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // Handle sign-in errors
              return const Text('Error signing in');
            } else if (snapshot.hasData) {
              // Sign-in successful, load data and then navigate
              return FutureBuilder(
                future: context
                    .read<SaveData>()
                    .loadData(), // Load data after sign-in
                builder: (context, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while data is being loaded
                    return const CircularProgressIndicator();
                  } else if (dataSnapshot.hasError) {
                    // Handle data loading errors
                    return const Text('Error loading data');
                  } else {
                    // Data is loaded, navigate to the next page
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MenuSelecter(index: 1)));
                    });
                    return Container(); // Placeholder while navigating
                  }
                },
              );
            } else {
              // Initial state, show the sign-in button
              return ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: const Text('Sign in with Google'),
              );
            }
          },
        ),
      ),
    );
  }
}
