import 'package:flutter/material.dart';
import 'transactions_page.dart';
import 'budget_page.dart';
import 'budget.dart';
import 'transaction.dart';

class MenuSelecter extends StatefulWidget {
  const MenuSelecter(
      {super.key,
      required this.budgets,
      required this.transactions,
      required this.index});

  final List<Budget> budgets;
  final List<Transaction> transactions;
  final int index;

  @override
  State<MenuSelecter> createState() => _MenuSelecterState();
}

class _MenuSelecterState extends State<MenuSelecter> {
  late int _currentIndex = widget.index;
  late List<Budget> currentBudgets = List.from(widget.budgets);
  late List<Transaction> currentTransactions = List.from(widget.transactions);

  @override
  void initState() {
    super.initState();
  }

  late List<Widget> body = [
    BudgetPage(
      title: 'Budget Page',
      budgets: currentBudgets,
      transactions: currentTransactions,
    ),
    TransactionsPage(
      title: 'Transactions Page',
      transactions: currentTransactions,
      budgets: currentBudgets,
    ),
    const Icon(Icons.person)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.article), label: "My Budget"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), label: "Transactions"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "People")
        ],
      ),
    );
  }
}
