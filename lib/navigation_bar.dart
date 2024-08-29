import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
  }

  late List<Widget> body = [
    const BudgetPage(),
    const TransactionsPage(title: 'Transactions Page'),
    const CashflowPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            Fluttertoast.cancel();
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.article), label: "My Budget"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), label: "Transactions"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: "Cashflow Statements")
        ],
      ),
    );
  }
}
