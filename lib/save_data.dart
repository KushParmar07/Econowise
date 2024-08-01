import 'package:flutter/material.dart';
import 'transaction_files/transaction.dart';
import 'budget_files/budget.dart';

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

  void updateTransactions(Budget budget) {
    double totalSpent = 0;
    DateTime endDate = budget.endDate!;
    DateTime startDate = budget.startDate!;

    for (var transaction in transactions) {
      if (transaction.spent &&
              transaction.date!.isBefore(endDate) &&
              transaction.date!.isAfter(startDate) ||
          DateUtils.isSameDay(startDate, transaction.date!) &&
              transaction.date!.isBefore(endDate)) {
        totalSpent += transaction.amount;
      }
    }

    budgets[budgets.indexOf(budget)].totalUsed = totalSpent;
  }
}
