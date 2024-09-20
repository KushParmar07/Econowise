import 'package:econowise/transaction_files/create_transaction.dart';
import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'transaction.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList(this.transactionItems, {super.key});
  final List<Transaction> transactionItems;

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  void showTransactionOptions(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  editTransaction(transaction);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  deleteTransaction(transaction);
                });
              },
            ),
          ],
        );
      },
    );
  }

  void deleteTransaction(Transaction transaction) {
    setState(() {
      context.read<SaveData>().deleteTransaction(transaction);
    });

    if (context.read<SaveData>().budgets.isNotEmpty) {
      for (var budget in context.read<SaveData>().budgets) {
        context.read<SaveData>().updateTransactions(budget);
      }
      context.read<SaveData>().saveData();
    }
  }

  void editTransaction(Transaction transaction) {
    setState(() {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => TransactionScreen(
                    currentTransaction: transaction,
                  )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.transactionItems.length,
        itemBuilder: (BuildContext context, index) {
          var transaction = widget.transactionItems[index];
          DateTime date = transaction.date ?? DateTime.now();
          return ListTile(
            tileColor: const Color.fromARGB(255, 228, 222, 222),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: transaction.budget.color,
                shape: BoxShape.circle,
              ),
              child: Icon(transaction.budget.icon, color: Colors.white),
            ),
            title: Text(
              transaction.title,
              style: const TextStyle(fontSize: 20),
            ),
            subtitle: Text(DateFormat("MMM, d, yyyy").format(date)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${transaction.spent ? "-" : "+"}\$${transaction.amount.toString()}",
                  style: TextStyle(
                      color: transaction.spent ? Colors.red : Colors.green,
                      fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    showTransactionOptions(transaction);
                  },
                ),
              ],
            ),
          );
        });
  }
}
