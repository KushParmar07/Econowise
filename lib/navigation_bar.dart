import 'package:econowise/save_data.dart';
import 'package:econowise/settings_files/settings.dart';
import 'package:flutter/material.dart';
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
  String appBarTitle = "Budgets";

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
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              },
              icon: const Icon(
                Icons.settings,
                size: 40,
              ))
        ],
      ),
      body: body[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
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
