import 'package:econowise/login_files/login.dart';
import 'package:econowise/navigation_bar.dart';
import 'package:econowise/save_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Color primaryColor = context.read<SaveData>().primaryColor;
  late Color secondaryColor = context.read<SaveData>().secondaryColor;

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
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        pickColor(context, buildColourPicker1());
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 100),
                    GestureDetector(
                      onTap: () {
                        pickColor(context, buildColourPicker2());
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 200),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          logoutUser(context);
                        },
                        child: const Text("Log Out")),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  Widget buildColourPicker1() => ColorPicker(
        pickerColor: primaryColor,
        onColorChanged: (colour) => setState(() {
          primaryColor = colour;
          context.read<SaveData>().primaryColourSet(colour);
        }),
      );
  Widget buildColourPicker2() => ColorPicker(
        pickerColor: secondaryColor,
        onColorChanged: (colour) => setState(() {
          secondaryColor = colour;
          context.read<SaveData>().secondaryColourSet(colour);
        }),
      );

  void pickColor(BuildContext context, Widget colourPicker) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Pick A Color"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              colourPicker,
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('SELECT'))
            ],
          )));
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
