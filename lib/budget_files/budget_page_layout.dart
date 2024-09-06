import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
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
          const Color.fromARGB(255, 179, 136, 235));
      selectedBudgetDetails = Budget(
          "Sample Budget",
          100,
          DateTime.now(),
          DateTime.now(),
          Icons.accessibility_rounded,
          const Color.fromARGB(255, 179, 136, 235));
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
    if (budget.budgetAmount * 0.85 < budget.totalUsed) {
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

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: budgets.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                budgetListDisplay(),
                displayGrayBackground(
                    size, budgetDetailsDisplay(percentageUsed)),
              ],
            )
          : createBudgetButton(),
    );
  }

  Expanded displayGrayBackground(Size size, Widget inside) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 228, 222, 222).withOpacity(0.3),
          ),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          color: const Color.fromARGB(255, 228, 222, 222).withOpacity(0.3),
        ),
        width: size.width,
        child: inside,
      ),
    );
  }

  SingleChildScrollView budgetDetailsDisplay(double percentageUsed) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 15),
          Text(
            selectedBudget.goal,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Icon(
            selectedBudgetDetails.icon,
            size: 60,
            color: selectedBudgetDetails.color,
          ),
          const SizedBox(height: 35),
          CircularPercentIndicator(
            radius: 150,
            lineWidth: 35,
            percent: percentageUsed,
            progressColor: selectedBudgetDetails.color,
            backgroundColor: selectedBudgetDetails.color.withOpacity(0.2),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Amount Used'),
                Text(
                  '\$${selectedBudgetDetails.totalUsed.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'of \$${selectedBudgetDetails.budgetAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SizedBox budgetListDisplay() {
    List<Budget> reversedBudgets = List.from(budgets.reversed);

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Scroll horizontally
        itemCount: reversedBudgets.length + 1, // Include the "Add" button
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: createBudget,
                    borderRadius: BorderRadius.circular(10),
                    child: Ink(
                      width: 50,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add, size: 30),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final budget = reversedBudgets[index - 1];
            final isSelected = budget == selectedBudget;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => changeActive(budget),
                    borderRadius: BorderRadius.circular(15),
                    child: Ink(
                      width: isSelected ? 130 : 120,
                      height: isSelected ? 160 : 140,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? budget.color.withOpacity(0.9)
                            : budget.color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: budget.color.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: const Offset(0, 10))
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 25,
                          ),
                          Text(
                            budget.goal,
                            style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: Colors.white,
                                fontSize: 16),
                          ),
                          Text('\$${budget.totalUsed.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white)),
                          Text(
                            'of \$${budget.budgetAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                          IconButton(
                              onPressed: () {
                                showBudgetOptions(budget);
                              },
                              icon: const Icon(Icons.more_horiz))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Center createBudgetButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: 300,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              createBudget();
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
                  "Create Budget",
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
}
