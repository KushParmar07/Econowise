import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'transaction.dart';
import 'package:provider/provider.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.transactionItems.length,
        itemBuilder: (BuildContext context, index) {
          var transaction = widget.transactionItems[index];
          return Card(
            color: transaction.spent ? Colors.red : Colors.green,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            transaction.title,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            transaction.date.toString().split(" ")[0],
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black38),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 8, 10),
                    child: Row(
                      children: [
                        Text(
                          '${transaction.amount.toString()}\$',
                          style: const TextStyle(fontSize: 15),
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
                  ),
                ],
              ),
            ),
          );
        });
  }
}
