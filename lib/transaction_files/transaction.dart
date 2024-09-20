import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econowise/budget_files/budget.dart';
import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';

class Transaction {
  String title;
  double amount;
  bool spent;
  DateTime? date;
  Budget budget;

  Transaction(this.title, this.amount, this.spent, this.date, this.budget);

  Map<String, dynamic> toJson() {
    // Check if the budget is a custom budget (not in _budgets)
    bool isCustomBudget = !SaveData().budgets.any((b) => b.goal == budget.goal);

    return {
      'title': title,
      'amount': amount,
      'spent': spent,
      'date': date,
      if (isCustomBudget)
        'budget': budget.toJson(), // Include budget details if custom
      if (!isCustomBudget)
        'budgetGoal': budget.goal, // Store budget goal if not custom
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    Budget transactionBudget;

    if (json.containsKey('budget')) {
      // Custom budget, create a Budget object from the included details
      transactionBudget = Budget.fromJson(json['budget']);
    } else {
      // Not a custom budget, find the matching Budget from _budgets
      transactionBudget = SaveData().budgets.firstWhere(
            (budget) => budget.goal == json['budgetGoal'],
            orElse: () => Budget('', 0, null, null, Icons.error, Colors.red, 0),
          );
    }

    return Transaction(
      json['title'],
      json['amount'],
      json['spent'],
      (json['date'] as Timestamp).toDate(),
      transactionBudget,
    );
  }
}
