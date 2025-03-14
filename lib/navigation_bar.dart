import 'package:econowise/login_files/login.dart';
import 'package:econowise/save_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'transaction_files/transactions_page.dart';
import 'budget_files/budget_page_layout.dart';
import 'cashflow_files/cashflow_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MenuSelecter extends StatefulWidget {
  const MenuSelecter({super.key, required this.index});

  final int index;

  @override
  State<MenuSelecter> createState() => _MenuSelecterState();
}

class _MenuSelecterState extends State<MenuSelecter> {
  late int _currentIndex = widget.index;
  String appBarTitle = "Transactions";

  @override
  void initState() {
    super.initState();
  }

  late List<Widget> body = [
    const BudgetPage(),
    const TransactionsPage(),
    const CashflowPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Define colors here for easier access and consistency
    const color1 = Color.fromARGB(255, 215, 195, 245); // Lighter Purple
    const color2 = Color.fromARGB(255, 185, 198, 248); // Lighter Blue
    // Don't use color3 (orange) in the AppBar, keep it blue/purple themed

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
        //catch
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: GoogleFonts.poppins(
            // Apply Google Fonts to AppBar title
            fontWeight: FontWeight.w600, // Semi-bold
            color: Colors.white, // White text
          ),
        ),
        centerTitle: true,
        // Use a gradient for the AppBar background
        flexibleSpace: Container(
          // Use flexibleSpace for the gradient
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color1, color2], // Use your color scheme
            ),
          ),
        ),
        elevation: 5, // Add a subtle shadow
        shadowColor: color1.withOpacity(0.5), // Consistent shadow color
        actions: [
          IconButton(
            onPressed: () => logoutUser(context),
            icon: const Icon(
              Icons.logout,
              size: 30, // Slightly smaller icon
              color: Colors.white, // White icon for contrast
            ),
          ),
        ],
      ),
      body: body[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: color2, // Use color2 for selected item
        unselectedItemColor: Colors.grey[600], // Unselected items in grey
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            Fluttertoast.cancel();
            _currentIndex = newIndex;
            switch (_currentIndex) {
              case 0:
                appBarTitle = "Budgets";
                break;
              case 1:
                appBarTitle = "Transactions";
                break;
              case 2:
                appBarTitle = "Overview";
                break;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.checklist_rtl), label: "Budgets"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: "Transactions"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Overview")
        ],
      ),
    );
  }
}
