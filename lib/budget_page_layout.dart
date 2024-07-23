import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE86583)),
        useMaterial3: true,
      ),
      home: BudgetPage(),
    );
  }
}

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final List<Map<String, dynamic>> budgets = [
    {
      'title': 'Entertainment',
      'amount': 25.00,
      'total': 100.00,
      'icon': Icons.movie,
      'color': const Color(0xFFFFC0CB),
    },
    {
      'title': 'Groceries',
      'amount': 82.50,
      'total': 200.00,
      'icon': Icons.shopping_cart,
      'color': const Color(0xFFD8B4F8),
    },
    {
      'title': 'Food',
      'amount': 70.00,
      'total': 150.00,
      'icon': Icons.restaurant,
      'color': const Color(0xFF90CAF9),
    },
    {
      'title': 'Clothes',
      'amount': 15.00,
      'total': 75.00,
      'icon': Icons.checkroom,
      'color': const Color(0xFFA5D6A7),
    },
  ];

  String selectedBudget = 'Groceries';

  @override
  Widget build(BuildContext context) {
    final selectedBudgetDetails =
        budgets.firstWhere((budget) => budget['title'] == selectedBudget);
    final percentageUsed =
        (selectedBudgetDetails['amount'] / selectedBudgetDetails['total'])
            .clamp(0.0, 1.0);

    return Scaffold(
      body: Column(
        children: [
          // Budget Cards and Add Button in a Row
          SizedBox(
            height: 160,
            child: Row(
              children: [
                // Add Button (taller, thinner)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      // Add your action for the Add button here
                    },
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
                      final isSelected = budget['title'] == selectedBudget;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () =>
                              setState(() => selectedBudget = budget['title']),
                          borderRadius: BorderRadius.circular(15),
                          child: Ink(
                            width: 120,
                            decoration: BoxDecoration(
                              color: budget['color'],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  budget['title'],
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                    '\$${budget['amount'].toStringAsFixed(2)}'),
                                Text(
                                  'of \$${budget['total'].toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
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

          // Selected Budget Details
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  selectedBudget,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Icon(
                  selectedBudgetDetails['icon'],
                  size: 60,
                  color: selectedBudgetDetails['color'],
                ),
                const SizedBox(height: 20),
                CircularPercentIndicator(
                  radius: 120,
                  lineWidth: 15,
                  percent: percentageUsed,
                  progressColor: Theme.of(context).colorScheme.secondary,
                  backgroundColor:
                      selectedBudgetDetails['color']!.withOpacity(0.3),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Amount Paid'),
                      Text(
                        '\$${selectedBudgetDetails['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'of \$${selectedBudgetDetails['total'].toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
