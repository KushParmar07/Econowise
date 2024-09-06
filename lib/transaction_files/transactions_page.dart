import 'package:econowise/transaction_files/create_transaction.dart';
import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'transactions_list.dart';
import 'package:provider/provider.dart';
import 'transaction.dart';

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
  String? sortOrder = 'Default';
  String? filterOptions = 'All';
  late List<Transaction> sortedTransactions =
      context.read<SaveData>().transactions;
  late List<Transaction> displayedTransactions = sortedTransactions;

  void createTransaction() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const TransactionScreen()));
  }

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: Consumer<SaveData>(builder: (context, data, child) {
          return data.transactions.isNotEmpty
              ? Column(
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          sortDropdown(data),
                          const SizedBox(width: 50),
                          filterDropdown()
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(child: TransactionsList(displayedTransactions)),
                    createTransactionButton()
                  ],
                )
              : createTransactionButton();
        }));
  }

  Center createTransactionButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: 300,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              createTransaction();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromARGB(255, 255, 131, 90),
                    Color.fromARGB(255, 128, 147, 241)
                  ],
                ),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Container(
                constraints: const BoxConstraints(minHeight: 60),
                alignment: Alignment.center,
                child: const Text(
                  "Create Transaction",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DropdownButton<String> filterDropdown() {
    return DropdownButton(
        value: filterOptions,
        items: <String>['All', 'Spent', 'Not Spent'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            filterOptions = newValue;

            filterSwitch();
          });
        });
  }

  DropdownButton<String> sortDropdown(SaveData data) {
    return DropdownButton(
        value: sortOrder,
        items: <String>[
          'Default',
          'Date Ascending',
          'Date Descending',
          'Amount Ascending',
          'Amount Descending'
        ].map((String value) {
          return DropdownMenuItem(
              value: value, child: Center(child: Text(value)));
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            sortOrder = newValue;

            switch (newValue) {
              case 'Default':
                sortedTransactions = data.transactions;
              case 'Date Ascending':
                sortedTransactions = data.dateSortedTransactionsAscending;
              case 'Date Descending':
                sortedTransactions = data.dateSortedTransactionsDescending;
              case 'Amount Ascending':
                sortedTransactions = data.amountSortedTransactionsAscending;
              case 'Amount Descending':
                sortedTransactions = data.amountSortedTransactionsDescending;
            }

            filterSwitch();
          });
        });
  }

  void filterSwitch() {
    switch (filterOptions) {
      case 'All':
        displayedTransactions = sortedTransactions;
        break;
      case 'Spent':
        displayedTransactions =
            sortedTransactions.where((tx) => tx.spent).toList();
        break;
      case 'Not Spent':
        displayedTransactions =
            sortedTransactions.where((tx) => !tx.spent).toList();
        break;
    }
  }
}
