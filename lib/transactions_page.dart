import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'transaction.dart';
import 'transactions_list.dart';
import 'navigation_bar.dart';
import 'budget.dart';
import 'package:provider/provider.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage(
      {super.key,
      required this.title,
      required this.transactions,
      required this.budgets});

  final String title;
  final List<Transaction> transactions;
  final List<Budget> budgets;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  bool spent = false;
  late DateTime? date = DateTime.now();

  Future openDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
              title: const Text('Enter Transaction'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                          labelText: 'Transaction Title',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue))),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: priceController,
                      decoration: const InputDecoration(
                          labelText: "Transaction Amount",
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue))),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Expense",
                          style: TextStyle(fontSize: 15),
                        ),
                        Switch(
                            value: spent,
                            activeColor: Colors.red,
                            onChanged: (bool value) {
                              {
                                setState(() {
                                  spent = value;
                                });
                              }
                            }),
                      ],
                    ),
                    TextField(
                      decoration: const InputDecoration(
                          labelText: 'DATE',
                          filled: true,
                          prefixIcon: Icon(Icons.calendar_month_rounded),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue))),
                      readOnly: true,
                      controller: dateController,
                      onTap: selectDate,
                    )
                  ],
                );
              }),
              actions: [
                TextButton(onPressed: submit, child: const Text("SUBMIT"))
              ]));

  Future<void> selectDate() async {
    date = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        initialDate: DateTime.now());

    setState(() {
      date != null
          ? dateController.text = date.toString().split(" ")[0]
          : dateController.text = DateTime.now().toString().split(" ")[0];
    });
  }

  void submit() {
    Navigator.of(context).pop();

    try {
      setState(() {
        context.read<SaveData>().addTransaction(Transaction(
            nameController.text, int.parse(priceController.text), spent, date));
      });
    } on Exception {
      // TODO
    }

    nameController.text = "";
    priceController.text = "";
    dateController.text = "";
    spent = false;
    date = DateTime.now();

    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => MenuSelecter(
                  budgets: widget.budgets,
                  transactions: const [],
                  index: 1,
                ),
            transitionDuration: Duration.zero));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Consumer<SaveData>(builder: (context, transaction, child) {
        return TransactionsList(transaction.transactions);
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: openDialog,
        tooltip: 'New Transaction',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
