import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'budget.dart';
import 'package:provider/provider.dart';
import 'create_budget.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late List<Budget> budgets;
  late String selectedBudget;
  int totalSpent = 0;
  late Budget selectedBudgetDetails;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    budgets = context.read<SaveData>().budgets;
    if (budgets.isNotEmpty) {
      selectedBudget = budgets[0].goal;
      selectedBudgetDetails =
          budgets.firstWhere((budget) => budget.goal == selectedBudget);
      startDate = selectedBudgetDetails.startDate!;
      endDate = selectedBudgetDetails.endDate!;
    } else {
      selectedBudget = "";
      selectedBudgetDetails = Budget("Sample Budget", 100, DateTime.now(),
          DateTime.now(), Icons.accessibility_rounded, Colors.purple);
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
      selectedBudget = budget.goal;
      selectedBudgetDetails =
          budgets.firstWhere((budget) => budget.goal == selectedBudget);
    });
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
        selectedBudget = context.read<SaveData>().budgets[0].goal;
        selectedBudgetDetails = context.read<SaveData>().budgets[0];
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
      appBar: AppBar(
        title: Text("Budget Page"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: budgets.isNotEmpty
          ? Column(
              children: [
                // Budget Cards and Add Button in a Row
                SizedBox(height: 15),
                SizedBox(
                  height: 160,
                  child: Row(
                    children: [
                      // Add Button (taller, thinner)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: createBudget,
                          borderRadius: BorderRadius.circular(10),
                          child: Ink(
                            width: 50,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add, size: 30),
                          ),
                        ),
                      ),

                      // Budget Category Cards
                      Expanded(
                        // This allows the cards to fill remaining space
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: budgets.length,
                          itemBuilder: (context, index) {
                            final budget = budgets[index];
                            final isSelected = budget.goal == selectedBudget;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () => changeActive(budget),
                                borderRadius: BorderRadius.circular(15),
                                child: Ink(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? budget.color
                                        : budget.color.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(15),
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
                                        ),
                                      ),
                                      Text(
                                          '\$${budget.totalUsed.toStringAsFixed(2)}'),
                                      Text(
                                        'of \$${budget.budgetAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 12),
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
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 228, 222, 222)
                            .withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      color: const Color.fromARGB(255, 228, 222, 222)
                          .withOpacity(0.3),
                    ),
                    width: size.width,
                    child: Column(
                      children: [
                        Text(
                          selectedBudget,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
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
                          backgroundColor:
                              selectedBudgetDetails.color.withOpacity(0.2),
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
                  ),
                ),
              ],
            )
          : Center(
              child: ElevatedButton(
                  onPressed: createBudget,
                  child: const Text("Please Create A Budget")),
            ),
    );
  }
}
