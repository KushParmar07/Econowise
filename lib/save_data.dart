import 'package:flutter/material.dart';
import 'transaction_files/transaction.dart';
import 'budget_files/budget.dart';

class SaveData extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  final List<Budget> _budgets = [];
  final List<String> _categories = [""];

  List<Transaction> get transactions => _transactions;
  List<Transaction> get dateSortedTransactionsDescending {
    List<Transaction> sortedTransactions = List.from(_transactions);
    sortedTransactions.sort((a, b) => b.date!.compareTo(a.date!));
    return sortedTransactions;
  }

  List<Transaction> get dateSortedTransactionsAscending {
    List<Transaction> sortedTransactions = List.from(_transactions);
    sortedTransactions.sort((a, b) => a.date!.compareTo(b.date!));
    return sortedTransactions;
  }

  List<Transaction> get amountSortedTransactionsAscending {
    List<Transaction> sortedTransactions = List.from(_transactions);
    sortedTransactions.sort((a, b) => a.amount.compareTo(b.amount));
    return sortedTransactions;
  }

  List<Transaction> get amountSortedTransactionsDescending {
    List<Transaction> sortedTransactions = List.from(_transactions);
    sortedTransactions.sort((a, b) => b.amount.compareTo(a.amount));
    return sortedTransactions;
  }

  List<Budget> get budgets => _budgets;
  List<String> get categories => _categories;

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
    notifyListeners();
  }

  void addBudget(Budget budget) {
    budgets.add(budget);
    notifyListeners();
  }

  void addCategory(String category) {
    if (!categories.contains(category)) {
      categories.add(category);
    }
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

  void deleteCategory(String category) {
    categories.remove(category);
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
              transaction.date!.isBefore(endDate) &&
              transaction.spent) {
        if (transaction.budget == budget) {
          totalSpent += transaction.amount;
        }
      }
    }

    budgets[budgets.indexOf(budget)].totalUsed = totalSpent;
  }
}
