class Transaction {
  String title;
  double amount;
  bool spent;
  DateTime? date;

  Transaction(this.title, this.amount, this.spent, this.date);
}
