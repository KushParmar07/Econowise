import 'package:econowise/transaction_files/create_transaction.dart';
import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'transactions_list.dart';
import 'package:provider/provider.dart';
import 'transaction.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String? sortOrder = 'Default';
  String? filterOptions = 'All';
  // Remove these.  They are now handled within the Consumer.
  // late List<Transaction> sortedTransactions;
  // late List<Transaction> displayedTransactions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No longer needed here.
    // sortedTransactions = Provider.of<SaveData>(context).transactions;
    // displayedTransactions = sortedTransactions;
    // filterSwitch(); // Initial filtering
  }

  void createTransaction() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const TransactionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    const color1 = Color.fromARGB(255, 215, 195, 245); // Lighter Purple
    const color2 = Color.fromARGB(255, 185, 198, 248); // Lighter Blue
    const color3 = Color.fromARGB(255, 255, 184, 157); // Lighter Orange
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color1.withOpacity(0.7), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  // Header with Dropdowns
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: sortDropdown(screenWidth),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          flex: 1,
                          child: filterDropdown(screenWidth),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Transaction List (using Consumer)
                  Expanded(
                    child: Consumer<SaveData>(
                      // Correctly placed Consumer
                      builder: (context, saveData, child) {
                        // *** SORTING LOGIC NOW HERE ***
                        List<Transaction> sortedTransactions =
                            List.from(saveData.transactions); // Create a *copy*

                        switch (sortOrder) {
                          case 'Date Ascending':
                            sortedTransactions
                                .sort((a, b) => a.date!.compareTo(b.date!));
                            break;
                          case 'Date Descending':
                            sortedTransactions
                                .sort((a, b) => b.date!.compareTo(a.date!));
                            break;
                          case 'Amount Ascending':
                            sortedTransactions
                                .sort((a, b) => a.amount.compareTo(b.amount));
                            break;
                          case 'Amount Descending':
                            sortedTransactions
                                .sort((a, b) => b.amount.compareTo(a.amount));
                            break;
                          case 'Default':
                          default: // Good practice to have a default case
                            // Already sorted by default (likely by insertion order)
                            break;
                        }

                        // *** FILTERING LOGIC (also inside the Consumer) ***
                        List<Transaction> displayedTransactions = [];
                        switch (filterOptions) {
                          case 'All':
                            displayedTransactions = sortedTransactions;
                            break;
                          case 'Expense':
                            displayedTransactions = sortedTransactions
                                .where((tx) => tx.spent)
                                .toList();
                            break;
                          case 'Income':
                            displayedTransactions = sortedTransactions
                                .where((tx) => !tx.spent)
                                .toList();
                            break;
                        }

                        return displayedTransactions.isNotEmpty
                            ? TransactionsList(displayedTransactions)
                            : Center(
                                child: Text("No transactions yet!",
                                    style: GoogleFonts.poppins()),
                              );
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.09)
                ],
              ),
              // Positioned Button
              Positioned(
                bottom: screenHeight * 0.02,
                left: 0,
                right: 0,
                child: createTransactionButton(screenWidth),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep this method, but remove padding/sizedbox issues from before.
  Center createTransactionButton(double screenWidth) {
    const color3 = Color.fromARGB(255, 255, 184, 157); // Lighter Orange
    const color1 = Color.fromARGB(255, 215, 195, 245); // Lighter Purple

    return Center(
      child: SizedBox(
        width: screenWidth * 0.75,
        height: screenWidth * 0.15,
        child: ElevatedButton(
          onPressed: () {
            createTransaction();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Transparent background
            padding: EdgeInsets.zero, // Remove default padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.075),
            ),
            elevation: 5, // Add a subtle shadow
            shadowColor: color1.withOpacity(0.5), // Shadow with color1
          ),
          child: Ink(
            // Use Ink for the gradient
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color1, color3], // Gradient from color1 to color3
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.075),
            ),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "Create Transaction",
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget filterDropdown(double screenWidth) {
    const color2 = Color.fromARGB(255, 185, 198, 248);

    return Theme(
      data: ThemeData(
        canvasColor: Colors.white,
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
              horizontal: 8, vertical: 4), // Reduced padding
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color2, width: 1.5), // Thinner border
            borderRadius: BorderRadius.circular(8), // Smaller radius
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: color2, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true, // Important for reducing height
        ),
        value: filterOptions,
        style: GoogleFonts.poppins(
            color: Colors.black, fontSize: screenWidth * 0.03), // Smaller font
        items: <String>['All', 'Expense', 'Income'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value,
                overflow: TextOverflow.ellipsis), // Prevent overflow
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            filterOptions = newValue;
          });
        },
        icon: Icon(Icons.filter_list, color: color2, size: screenWidth * 0.05),
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget sortDropdown(double screenWidth) {
    const color1 = Color.fromARGB(255, 215, 195, 245);

    return Theme(
      data: ThemeData(
        canvasColor: Colors.white,
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
              horizontal: 8, vertical: 4), //Reduced padding
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color1, width: 1.5), //Thinner border
            borderRadius: BorderRadius.circular(8), //Smaller radius
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: color1, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true, // Important for reducing height
        ),
        value: sortOrder,
        style: GoogleFonts.poppins(
            color: Colors.black, fontSize: screenWidth * 0.03), //Smaller font
        items: <String>[
          'Default',
          'Date Ascending',
          'Date Descending',
          'Amount Ascending',
          'Amount Descending'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value,
                overflow: TextOverflow.ellipsis), // Prevent overflow
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            sortOrder = newValue!; // Update sortOrder
            // No need to call filterSwitch or sortTransactions here
          });
        },
        icon: Icon(Icons.sort, color: color1, size: screenWidth * 0.05),
        dropdownColor: Colors.white,
      ),
    );
  }
}
