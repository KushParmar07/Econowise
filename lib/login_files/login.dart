
import 'package:econowise/navigation_bar.dart';
import 'package:econowise/save_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isLoading = false;
  String? _errorMessage;

  Future<UserCredential?> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Sign in was cancelled.";
        });
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error signing in with Google: $e";
      });
      return null;
    }
  }

  Future<void> _handleSignIn() async {
    UserCredential? userCredential = await signInWithGoogle();
    if (userCredential != null) {
      try {
        await context.read<SaveData>().loadData();
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const MenuSelecter(index: 1)),
          );
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error loading data: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define your colors
    const color1 = Color.fromARGB(255, 179, 136, 235);
    const color2 = Color.fromARGB(255, 128, 147, 241);
    const color3 = Color.fromARGB(255, 255, 131, 90);

    return Scaffold(body: LayoutBuilder(builder: (context, constraints) {
      // Get screen dimensions
      final screenWidth = constraints.maxWidth;
      final screenHeight = constraints.maxHeight;

      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2],
          ),
        ),
        child: SingleChildScrollView(
          // Make scrollable
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Center(
              child: Padding(
                padding:
                    EdgeInsets.all(screenWidth * 0.05), // 5% of screen width
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular Logo with Subtle Border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: screenWidth * 0.01, // 1% of screen width
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: EdgeInsets.all(
                              screenWidth * 0.08), // 8% of screen width
                          child: Image.asset(
                            'assets/EconowiseLogo.png',
                            width: screenWidth * 0.25, // 25% of screen width
                            height: screenWidth *
                                0.25, // 25% of screen width - keep it square
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: screenHeight * 0.05), // 5% of screen height

                    // Neumorphic Container for button and error
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            screenWidth * 0.0625), // 6.25% of screen width
                        color: Colors.white.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            offset: const Offset(-6.0, -6.0),
                            blurRadius: 16.0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(6.0, 6.0),
                            blurRadius: 16.0,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white30,
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.all(
                          screenWidth * 0.05), // 5% of screen width
                      child: Column(
                        children: [
                          _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color3),
                                )
                              : GoogleSignInButton(
                                  onPressed: _handleSignIn,
                                  screenWidth: screenWidth),
                          SizedBox(
                              height:
                                  screenHeight * 0.02), // 2% of screen height
                          if (_errorMessage != null)
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize:
                                    screenWidth * 0.035, // 3.5% of screen width
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }));
  }
}

// Custom Google Sign-In Button (Cooler Version)
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double screenWidth; // Add screenWidth

  const GoogleSignInButton(
      {super.key, required this.onPressed, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    const color3 = Color.fromARGB(255, 255, 131, 90);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            screenWidth * 0.0625), // 6.25% of screen width
        gradient: LinearGradient(
          colors: [
            color3.withOpacity(0.8),
            color3,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color3.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.035, // 3.5% of screen width
            horizontal: screenWidth * 0.06, // 6% of screen width
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                screenWidth * 0.0625), // 6.25% of screen width
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        label: Text(
          'Sign in with Google',
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.045, // 4.5% of screen width
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
