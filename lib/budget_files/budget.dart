import 'package:flutter/material.dart';

class Budget {
  String goal;
  double budgetAmount;
  DateTime? startDate;
  DateTime? endDate;
  IconData icon;
  double totalUsed = 0;
  Color color = Colors.blue;
  double warningAmount = 0;
  Budget(this.goal, this.budgetAmount, this.startDate, this.endDate, this.icon,
      this.color, this.warningAmount);
}
