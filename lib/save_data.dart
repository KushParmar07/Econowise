import 'package:flutter/material.dart';
import 'transaction.dart';
import 'budget.dart';

class SaveData extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  final List<Budget> _budgets = [];

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
