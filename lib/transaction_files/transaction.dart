import 'package:econowise/budget_files/budget.dart';

class Transaction {
  String title;
  double amount;
  bool spent;
  DateTime? date;
  Budget budget;

  Transaction(this.title, this.amount, this.spent, this.date, this.budget);
}
