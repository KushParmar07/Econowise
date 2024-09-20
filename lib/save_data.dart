import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'transaction_files/transaction.dart' as transaction;
import 'budget_files/budget.dart';

class SaveData extends ChangeNotifier {
  final List<transaction.Transaction> _transactions = [];
  final List<Budget> _budgets = [];
  int _activeMonth = DateTime.now().month;
  int _activeYear = DateTime.now().year;
  bool _isMonthlyView = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Color primaryColor = const Color.fromARGB(255, 255, 131, 90);
  Color secondaryColor = const Color.fromARGB(255, 128, 147, 241);

  // Load data from Firestore when the user logs in
  Future<void> loadData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(user.uid).get();

        if (userSnapshot.exists) {
          _budgets.clear();
          _transactions.clear();

          List<dynamic> budgetData = userSnapshot.get('budgets');
          for (var budgetJson in budgetData) {
            _budgets.add(Budget.fromJson(budgetJson));
          }

          List<dynamic> transactionData = userSnapshot.get('transactions');
          for (var transactionJson in transactionData) {
            _transactions
                .add(transaction.Transaction.fromJson(transactionJson));
          }

          notifyListeners(); // Notify listeners after loading data
        }
      }
    } catch (e) {
      //catch
    }
  }

  // Save data to Firestore whenever there's a change
  Future<void> saveData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'budgets': _budgets.map((budget) => budget.toJson()).toList(),
          'transactions':
              _transactions.map((transaction) => transaction.toJson()).toList(),
        });
      }
    } catch (e) {
      //catch
    }
  }

  List<transaction.Transaction> get transactions => _transactions;
  List<transaction.Transaction> get dateSortedTransactionsDescending {
    List<transaction.Transaction> sortedTransactions = List.from(_transactions);
    sortedTransactions.sort((a, b) => b.date!.compareTo(a.date!));
    return sortedTransactions;
  }

  List<transaction.Transaction> get dateSortedTransactionsAscending {
    List<transaction.Transaction> sortedTransactions = List.from(_transactions);
    sortedTransactions.sort((a, b) => a.date!.compareTo(b.date!));
    return sortedTransactions;
  }

  List<transaction.Transaction> get amountSortedTransactionsAscending {
    List<transaction.Transaction> sortedTransactions = List.from(_transactions);
    sortedTransactions.sort((a, b) => a.amount.compareTo(b.amount));
    return sortedTransactions;
  }

  List<transaction.Transaction> get amountSortedTransactionsDescending {
    List<transaction.Transaction> sortedTransactions = List.from(_transactions);
    sortedTransactions.sort((a, b) => b.amount.compareTo(a.amount));
    return sortedTransactions;
  }

  List<Budget> get budgets => _budgets;

  int get activeMonth => _activeMonth;
  int get activeYear => _activeYear;
  bool get isMonthlyView => _isMonthlyView;

  void addTransaction(transaction.Transaction transaction) {
    transactions.add(transaction);
    notifyListeners();
    if (!transaction.spent) {
      saveData();
    }
  }

  void addBudget(Budget budget) {
    budgets.add(budget);
    notifyListeners();
  }

  void deleteTransaction(transaction.Transaction transaction) {
    transactions.remove(transaction);
    notifyListeners();
    saveData();
  }

  void deleteBudget(Budget budget) {
    budgets.remove(budget);
    notifyListeners();
    for (var transaction in transactions) {
      if (transaction.budget.hashCode == budget.hashCode) {
        transaction.budget = Budget("sample", 0, DateTime.now(), DateTime.now(),
            Icons.money_off, Colors.red, 0);
      }
    }
    saveData();
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

  set activeMonth(int month) {
    _activeMonth = month;
    notifyListeners(); // Notify listeners about the change
  }

  set activeYear(int year) {
    _activeYear = year;
    notifyListeners();
  }

  set isMonthlyView(bool isMonthly) {
    _isMonthlyView = isMonthly;
    notifyListeners();
  }

  void primaryColourSet(Color colour) {
    primaryColor = colour;
    notifyListeners();
  }

  void secondaryColourSet(Color colour) {
    secondaryColor = colour;
    notifyListeners();
  }
}
