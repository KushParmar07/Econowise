import 'package:flutter/material.dart';
import 'budget.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'transaction.dart';
import 'create_budget.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late TextEditingController goalController;
  late TextEditingController budgetController;
  late List<Transaction> transactions = [];
  late List<Budget> currentBudgets = [];
  late Budget currentBudget;
  int totalSpent = 0;
  late DateTime startDate;
  late DateTime endDate;

  void createBudget() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const BudgetScreen()));
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

  @override
  void initState() {
    super.initState();
    goalController = TextEditingController();
    budgetController = TextEditingController();

    if (currentBudgets.isNotEmpty) {
      currentBudget = currentBudgets[currentBudgets.length - 1];
    } else {
      currentBudget = Budget("Sample Budget", 100, DateTime.now(),
          DateTime.now(), Icons.accessibility_rounded);
    }
    startDate = currentBudget.startDate!;
    endDate = currentBudget.endDate!;
    updateTransactions();
  }

  void updateTransactions() {
    totalSpent = 0;
    for (var transaction in transactions) {
      if (transaction.spent &&
          transaction.date!.isAfter(startDate) &&
          transaction.date!.isBefore(endDate)) {
        totalSpent += transaction.amount;
      }
    }

    setState(() {
      currentBudget.totalUsed = totalSpent;
    });
  }

  void deleteBudget(Budget budget) {
    setState(() {
      currentBudgets.remove(budget);
      if (currentBudgets.isNotEmpty) {
        currentBudget = currentBudgets[currentBudgets.length - 1];
      }
    });
  }

  void editBudget(Budget budget) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BudgetScreen(currentBudget: currentBudget)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createBudget,
          tooltip: "Create Budget",
          child: const Icon(Icons.add),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                DropdownButton(
                  value: currentBudget,
                  items: currentBudgets
                      .map((budget) => DropdownMenuItem(
                          value: budget, child: Text(budget.goal)))
                      .toList(),
                  onChanged: (budget) => setState(() {
                    currentBudget = budget!;
                    currentBudget.totalUsed = totalSpent;
                    startDate = currentBudget.startDate!;
                    endDate = currentBudget.endDate!;
                    updateTransactions();
                  }),
                ),
                Row(
                  children: [
                    Text(
                      currentBudget.goal,
                      style: const TextStyle(fontSize: 30),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Icon(currentBudget.icon)
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Total Budget: ${currentBudget.budgetAmount.toString()}\$',
                      style: const TextStyle(fontSize: 25),
                    ),
                    IconButton(
                        onPressed: () {
                          showBudgetOptions(currentBudget);
                        },
                        icon: const Icon(Icons.more_vert))
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "From: ",
                      style: TextStyle(
                          fontSize: 20, color: Colors.pinkAccent[700]),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(
                      currentBudget.startDate.toString().split(" ")[0],
                      style: TextStyle(
                          fontSize: 20, color: Colors.pinkAccent[700]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "To: ",
                      style: TextStyle(
                          fontSize: 20, color: Colors.pinkAccent[700]),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(
                      currentBudget.endDate.toString().split(" ")[0],
                      style: TextStyle(
                          fontSize: 20, color: Colors.pinkAccent[700]),
                    ),
                  ],
                ),
                Expanded(
                  child: CircularPercentIndicator(
                    radius: 150.0,
                    lineWidth: 50.0,
                    percent: currentBudget.totalUsed /
                                    currentBudget.budgetAmount <=
                                1 &&
                            currentBudget.totalUsed /
                                    currentBudget.budgetAmount >=
                                0
                        ? currentBudget.totalUsed / currentBudget.budgetAmount
                        : 1,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentBudget.budgetAmount != 0
                              ? '${(currentBudget.totalUsed / currentBudget.budgetAmount * 100).round().toString()}% Used'
                              : "No Budget",
                          style: const TextStyle(fontSize: 30),
                        ),
                        Text(
                          '\$ Left: ${currentBudget.budgetAmount - currentBudget.totalUsed}',
                          style: const TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                    progressColor: const Color.fromARGB(255, 175, 41, 41),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
