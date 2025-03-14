import 'package:econowise/transaction_files/create_transaction.dart';
import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'transaction.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsList extends StatefulWidget {
  final List<Transaction> transactionItems;

  const TransactionsList(this.transactionItems, {super.key});

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
                editTransaction(transaction);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                deleteTransaction(transaction);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteTransaction(Transaction transaction) {
    context.read<SaveData>().deleteTransaction(transaction);
    if (context.read<SaveData>().budgets.isNotEmpty) {
      for (var budget in context.read<SaveData>().budgets) {
        context.read<SaveData>().updateTransactions(budget);
      }
      context.read<SaveData>().saveData();
    }
    setState(() {}); // Rebuild after deleting
  }

  void editTransaction(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TransactionScreen(currentTransaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView.separated(
      padding:
          EdgeInsets.all(screenWidth * 0.04), // Add padding around the list
      itemCount: widget.transactionItems.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: screenHeight * 0.01), // Space between cards
      itemBuilder: (BuildContext context, index) {
        var transaction = widget.transactionItems[index];
        DateTime date = transaction.date ?? DateTime.now();
        return Card(
          elevation: 2,
          margin: EdgeInsets.zero, // Remove margin from Card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          color: Colors.white,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            leading: Container(
              width: screenWidth * 0.1, // Slightly larger
              height: screenWidth * 0.1,
              decoration: BoxDecoration(
                color: transaction.budget.color,
                shape: BoxShape.circle,
              ),
              child: Icon(transaction.budget.icon,
                  color: Colors.white, size: screenWidth * 0.06), // Larger icon
            ),
            title: Text(
              transaction.title,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.045, // Slightly larger
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              DateFormat("MMM, d, yyyy").format(date),
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.035, // Slightly larger
                color: Colors.grey[600], // Darker grey for better readability
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${transaction.spent ? "-" : "+"}\$${transaction.amount.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                    color: transaction.spent ? Colors.red : Colors.green,
                    fontSize: screenWidth * 0.04, // Slightly larger
                    fontWeight: FontWeight.w500,
                  ),
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
        );
      },
    );
  }
}
