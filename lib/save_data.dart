import 'package:flutter/material.dart';
import 'transaction.dart';
import 'budget.dart';

class SaveData extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  final List<Budget> _budgets = [
    Budget("Test", 500, DateTime.now(), DateTime.now().add(Duration(days: 31)),
        Icons.shopping_cart)
  ];

  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
    notifyListeners();
  }

  void addBudget(Budget budget) {
    budgets.add(budget);
    notifyListeners();
  }

  void deleteTransaction(Transaction transaction) {
    transactions.remove(transaction);
    notifyListeners();
  }

  void deleteBudget(Budget budget) {
    budgets.remove(budget);
    notifyListeners();
  }
}
