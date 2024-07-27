import 'package:flutter/material.dart';
import 'transaction.dart';

class SaveData extends ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
    notifyListeners();
  }

  void deleteTransaction(Transaction transaction) {
    transactions.remove(transaction);
    notifyListeners();
  }
}
