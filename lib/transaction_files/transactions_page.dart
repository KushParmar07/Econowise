import 'package:econowise/transaction_files/create_transaction.dart';
import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'transactions_list.dart';
import 'package:provider/provider.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  bool spent = false;
  late DateTime? date = DateTime.now();

  void createTransaction() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const TransactionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Consumer<SaveData>(builder: (context, data, child) {
        return data.transactions.isNotEmpty
            ? TransactionsList(data.transactions)
            : const Center(child: Text("Please Create A Transaction"));
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: createTransaction,
        tooltip: 'New Transaction',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
