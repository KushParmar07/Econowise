import 'package:flutter/material.dart';

class Budget {
  String goal;
  int budgetAmount;
  DateTime? startDate;
  DateTime? endDate;
  IconData icon;
  int totalUsed = 0;
  Color color = Colors.blue;

  Budget(this.goal, this.budgetAmount, this.startDate, this.endDate, this.icon,
      this.color);
}
