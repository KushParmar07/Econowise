class Transaction {
  String title;
  double amount;
  bool spent;
  DateTime? date;
  String category;

  Transaction(this.title, this.amount, this.spent, this.date, this.category);
}
