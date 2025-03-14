// ignore_for_file: deprecated_member_use

import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:percent_indicator/percent_indicator.dart';
import 'budget.dart';
import 'package:provider/provider.dart';
import 'create_budget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late List<Budget> budgets;
  late Budget selectedBudget;
  int totalSpent = 0;
  late Budget selectedBudgetDetails;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    budgets = context.read<SaveData>().budgets;
    if (budgets.isNotEmpty) {
      selectedBudget = budgets[budgets.length - 1];
      selectedBudgetDetails =
          budgets.firstWhere((budget) => budget == selectedBudget);
      startDate = selectedBudgetDetails.startDate!;
      endDate = selectedBudgetDetails.endDate!;
      warning(selectedBudgetDetails);
    } else {
      selectedBudget = Budget(
          "Sample Budget",
          100,
          DateTime.now(),
          DateTime.now(),
          Icons.accessibility_rounded,
          const Color.fromARGB(255, 179, 136, 235),
          0);
      selectedBudgetDetails = Budget(
          "Sample Budget",
          100,
          DateTime.now(),
          DateTime.now(),
          Icons.accessibility_rounded,
          const Color.fromARGB(255, 179, 136, 235),
          0);
      startDate = DateTime.now();
      endDate = DateTime.now();
    }
  }

  void createBudget() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const BudgetScreen()));
  }

  void changeActive(Budget budget) {
    setState(() {
      selectedBudget = budget;
      selectedBudgetDetails =
          budgets.firstWhere((budget) => budget == selectedBudget);
    });

    warning(budget);
  }

  void warning(Budget budget) {
    if (budget.warningAmount > 0) {
      if (budget.totalUsed >= budget.warningAmount) {
        Fluttertoast.showToast(
            msg: budget.totalUsed < budget.budgetAmount
                ? 'WARNING: "${budget.goal}" Is Almost Used Up'
                : 'WARNING: "${budget.goal}" Has Been Used Up',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: budget.color,
            textColor: Colors.white,
            fontSize: 20);
      }
    }
  }

  void showBudgetOptions(Budget budget) {
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
                editBudget(budget);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  deleteBudget(budget);
                });
              },
            ),
          ],
        );
      },
    );
  }

  void deleteBudget(Budget budget) {
    setState(() {
      context.read<SaveData>().deleteBudget(budget);
      if (context.read<SaveData>().budgets.isNotEmpty &&
          budget.goal == selectedBudget) {
        selectedBudget = context.read<SaveData>().budgets[0];
        selectedBudgetDetails = context.read<SaveData>().budgets[0];
        warning(selectedBudgetDetails);
      }
    });
  }

  void editBudget(Budget budget) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BudgetScreen(currentBudget: budget)));
  }

  @override
  Widget build(BuildContext context) {
    final percentageUsed =
        (selectedBudgetDetails.totalUsed / selectedBudgetDetails.budgetAmount)
            .clamp(0.0, 1.0);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const color1 = Color.fromARGB(255, 215, 195, 245); // Lighter Purple
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
          child: context.watch<SaveData>().budgets.isNotEmpty // Use Consumer
              ? SingleChildScrollView(
                  // Wrap the ENTIRE Column in SingleChildScrollView
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          height: screenHeight * 0.02), // Consistent spacing
                      budgetListDisplay(),
                      SizedBox(
                          height: screenHeight *
                              0.02), // Space between list and details
                      //  **** THIS IS WHERE IT NEEDS TO BE ****
                      budgetDetailsDisplay(
                          percentageUsed, screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.05)
                    ],
                  ),
                )
              : Center(
                  child: createBudgetButton(screenWidth)), // Centered button
        ),
      ),
    );
  }

  Center createBudgetButton(double screenWidth) {
    const color3 = Color.fromARGB(255, 255, 184, 157); // Lighter Orange
    const color1 = Color.fromARGB(255, 215, 195, 245); // Lighter Purple

    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SizedBox(
          width: screenWidth * 0.75,
          height: screenWidth * 0.15,
          child: ElevatedButton(
            onPressed: () {
              createBudget();
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
                gradient: const LinearGradient(
                  colors: [color1, color3], // Gradient from color1 to color3
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(screenWidth * 0.075),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Create Budget",
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
      ),
    );
  }

  Widget budgetDetailsDisplay(
      double percentageUsed, double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05), // Margins around the container
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 215, 195, 245)
                .withOpacity(0.25), // Keep a VERY subtle shadow
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        // Removed SingleChildScrollView, as whole page is scrollable
        children: [
          SizedBox(height: screenHeight * 0.02),
          Text(
            selectedBudget.goal,
            style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: screenHeight * 0.01),
          Icon(
            selectedBudgetDetails.icon,
            size: screenWidth * 0.15, // Relative icon size
            color: selectedBudgetDetails.color,
          ),
          SizedBox(
              height: screenHeight * 0.04), // More space before the indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: CircularPercentIndicator(
              radius: screenWidth * 0.30, // Relative radius
              lineWidth: screenWidth * 0.07, // Relative line width
              percent: percentageUsed,
              progressColor: selectedBudgetDetails.color,
              backgroundColor: selectedBudgetDetails.color.withOpacity(0.2),
              circularStrokeCap:
                  CircularStrokeCap.round, // Rounded ends for the progress bar
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Amount Used',
                    style: GoogleFonts.poppins(fontSize: screenWidth * 0.035),
                  ),
                  Text(
                    '\$${selectedBudgetDetails.totalUsed.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.05, // Larger font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'of \$${selectedBudgetDetails.budgetAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(fontSize: screenWidth * 0.03),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
        ],
      ),
    );
  }

  Widget budgetListDisplay() {
    List<Budget> reversedBudgets = List.from(budgets.reversed);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight =
        MediaQuery.of(context).size.height; // Get screen height

    return SizedBox(
      height: screenHeight * 0.22, // Use screenHeight for relative height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reversedBudgets.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Add Budget" Button
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenHeight * 0.01), // Relative padding
              child: InkWell(
                onTap: createBudget,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: screenWidth * 0.15, // Relative width
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.add,
                      size: screenWidth * 0.07), // Relative icon size
                ),
              ),
            );
          } else {
            // Budget Cards
            final budget = reversedBudgets[index - 1];
            final isSelected = budget == selectedBudget;

            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenHeight * 0.01), // Relative padding
              child: InkWell(
                onTap: () => changeActive(budget),
                borderRadius: BorderRadius.circular(15),
                child: AnimatedContainer(
                  // Use AnimatedContainer
                  duration:
                      const Duration(milliseconds: 200), // Animation duration
                  curve: Curves.easeInOut, // Animation curve
                  width: isSelected ? screenWidth * 0.35 : screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? budget.color.withOpacity(0.9)
                        : budget.color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: budget.color
                                  .withOpacity(0.4), // Stronger shadow
                              spreadRadius: 2,
                              blurRadius: 8, // Increased blur
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.01), // Relative spacing
                      Text(
                        budget.goal,
                        style: GoogleFonts.poppins(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                      Text(
                        '\$${budget.totalUsed.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: screenWidth * 0.03,
                        ), // Added font size
                      ),
                      Text(
                        'of \$${budget.budgetAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.025,
                            color: Colors.white), // Added font size
                      ),
                      IconButton(
                          onPressed: () {
                            showBudgetOptions(budget);
                          },
                          icon: const Icon(Icons.more_horiz),
                          color: Colors.white) // Added color
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
