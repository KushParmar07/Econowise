import 'dart:math';

import 'package:econowise/budget_files/budget.dart';
import 'package:econowise/transaction_files/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:econowise/save_data.dart';

class CashflowPage extends StatefulWidget {
  const CashflowPage({super.key});

  @override
  State<CashflowPage> createState() => _CashflowPageState();
}

class _CashflowPageState extends State<CashflowPage> {
  int activeMonth = DateTime.now().month;
  int activeYear = DateTime.now().year;
  bool isMonthlyView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Overview"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            topBar(
                activeMonth,
                activeYear,
                nextMonth,
                lastMonth,
                isMonthlyView
                    ? getTotalIncome(activeMonth, activeYear)
                    : getTotalIncomeForYear(activeYear),
                getTotalIncomeChange(),
                isMonthlyView
                    ? getTotalExpenses(activeMonth, activeYear)
                    : getTotalExpensesForYear(activeYear),
                getTotalExpenseChange(),
                getTotalCashflowChange(),
                isMonthlyView,
                toggleView),
            Consumer<SaveData>(
              builder: (context, saveData, _) {
                final transactions = saveData.transactions;
                final chartSeries =
                    getChartSeriesData().cast<CartesianSeries>();
                final axisRange = calculateYAxisRange(transactions);

                return SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  primaryYAxis: NumericAxis(
                    minimum: axisRange.$1,
                    maximum: axisRange.$2,
                    interval: axisRange.$3,
                    labelFormat: '{value}', // Display the raw value
                    numberFormat: NumberFormat.compactCurrency(
                      // Use compact currency formatting
                      symbol: '\$',
                      decimalDigits: 0, // No decimal places
                    ),
                    labelStyle: const TextStyle(
                        overflow: TextOverflow
                            .visible), // Allow labels to overflow and wrap
                  ),
                  series: chartSeries,
                  onSelectionChanged: (SelectionArgs args) {
                    if (args.pointIndex != null &&
                        args.seriesIndex != null &&
                        args.seriesIndex! < chartSeries.length) {
                      final series =
                          chartSeries[args.seriesIndex!] as StackedColumnSeries;
                      final budgetName = series.name ?? 'Other';

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Budget: $budgetName')),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void nextMonth() {
    setState(() {
      if (isMonthlyView) {
        activeMonth += 1;
        if (activeMonth > 12) {
          activeMonth = 1;
          activeYear += 1;
        }
      } else {
        activeYear += 1;
      }
    });
  }

  void lastMonth() {
    setState(() {
      if (isMonthlyView) {
        activeMonth -= 1;
        if (activeMonth < 1) {
          activeMonth = 12;
          activeYear -= 1;
        }
      } else {
        activeYear -= 1;
      }
    });
  }

  void toggleView() {
    setState(() {
      isMonthlyView = !isMonthlyView;
    });
  }

  num getTotalIncome(int month, int year) {
    num totalIncome = 0;
    for (var transaction in context.read<SaveData>().transactions) {
      if (transaction.date!.month == month &&
          transaction.date!.year == year &&
          !transaction.spent) {
        totalIncome += transaction.amount;
      }
    }
    return totalIncome;
  }

  num getTotalExpenses(int month, int year) {
    num totalExpenses = 0;
    for (var transaction in context.read<SaveData>().transactions) {
      if (transaction.date!.month == month &&
          transaction.date!.year == year &&
          transaction.spent) {
        totalExpenses += transaction.amount;
      }
    }
    return totalExpenses;
  }

  num getTotalIncomeChange() {
    if (isMonthlyView) {
      return (getTotalIncome(activeMonth, activeYear) -
              getTotalIncome(activeMonth - 1, activeYear)) /
          getTotalIncome(activeMonth - 1, activeYear) *
          100;
    } else {
      int previousYear = activeYear - 1;
      num currentYearIncome = getTotalIncomeForYear(activeYear);
      num previousYearIncome = getTotalIncomeForYear(previousYear);

      return ((currentYearIncome - previousYearIncome) / previousYearIncome) *
          100;
    }
  }

  num getTotalExpenseChange() {
    if (isMonthlyView) {
      return (getTotalExpenses(activeMonth, activeYear) -
              getTotalExpenses(activeMonth - 1, activeYear)) /
          getTotalExpenses(activeMonth - 1, activeYear) *
          100;
    } else {
      int previousYear = activeYear - 1;
      num currentYearExpenses = getTotalExpensesForYear(activeYear);
      num previousYearExpenses = getTotalExpensesForYear(previousYear);

      return ((currentYearExpenses - previousYearExpenses) /
              previousYearExpenses) *
          100;
    }
  }

  num getTotalCashflowChange() {
    if (isMonthlyView) {
      num currentMonthCashflow = getTotalIncome(activeMonth, activeYear) -
          getTotalExpenses(activeMonth, activeYear);
      num previousMonthCashflow = getTotalIncome(activeMonth - 1, activeYear) -
          getTotalExpenses(activeMonth - 1, activeYear);

      num absoluteChange = currentMonthCashflow - previousMonthCashflow;
      num percentageChange =
          (absoluteChange / previousMonthCashflow.abs()) * 100;

      return percentageChange;
    } else {
      int previousYear = activeYear - 1;
      num currentYearCashflow = getTotalIncomeForYear(activeYear) -
          getTotalExpensesForYear(activeYear);
      num previousYearCashflow = getTotalIncomeForYear(previousYear) -
          getTotalExpensesForYear(previousYear);

      num absoluteChange = currentYearCashflow - previousYearCashflow;
      num percentageChange =
          (absoluteChange / previousYearCashflow.abs()) * 100;

      return percentageChange;
    }
  }

  num getTotalIncomeForYear(int year) {
    num totalIncome = 0;
    for (var transaction in context.read<SaveData>().transactions) {
      if (transaction.date!.year == year && !transaction.spent) {
        totalIncome += transaction.amount;
      }
    }
    return totalIncome;
  }

  num getTotalExpensesForYear(int year) {
    num totalExpenses = 0;
    for (var transaction in context.read<SaveData>().transactions) {
      if (transaction.date!.year == year && transaction.spent) {
        totalExpenses += transaction.amount;
      }
    }
    return totalExpenses;
  }

  (double, double, double) calculateYAxisRange(List<Transaction> transactions) {
    double range = 0;
    for (var transaction in transactions) {
      if (transaction.date != null &&
          transaction.date!.month == activeMonth &&
          transaction.date!.year == activeYear) {
        double transactionValue =
            transaction.spent ? -transaction.amount : transaction.amount;
        range = max(range, transactionValue.abs());
      }
    }

    // Handle the case where there are no transactions
    if (range == 0) {
      range = 500;
    }

    // Round up the range to the nearest 100 up to 1000
    if (range <= 1000) {
      range = (range / 100).ceil() * 100;
    }
    // Round up to the nearest 1000 between 1000 and 10000
    else if (range > 1000 && range < 10000) {
      range = ((range + 500) / 1000).ceil() * 1000;
    }
    // For values above 10000, round up to the nearest 5000 or multiple of 10000, etc.
    else {
      int powerOfTen = (range.abs().toString().length - 1).clamp(2, 5);
      double intervalBase = pow(10, powerOfTen).toDouble();
      if (range / intervalBase > 0.5) {
        range = (range / intervalBase).ceil() * intervalBase;
      } else {
        range = (range / (intervalBase / 10)).ceil() * (intervalBase / 10);
      }
    }

    // Calculate interval
    double interval = 100 + ((range - 100) / 500).floor() * 100;

    return (-range, range, interval);
  }

  List<ChartSeries<ChartData, String>> getChartSeriesData() {
    List<Transaction> transactions = context.read<SaveData>().transactions;
    List<Budget> budgets = context.read<SaveData>().budgets;

    // 1. Get all weeks of the active month
    List<DateTimeRange> weeksOfMonth = getWeeksOfMonth(activeYear, activeMonth);

    // 2. Initialize weeklyBudgetExpenses with all weeks and budgets (or 'Other')
    Map<DateTimeRange, Map<String, num>> weeklyBudgetExpenses = {};
    for (var weekRange in weeksOfMonth) {
      weeklyBudgetExpenses[weekRange] = {};
      if (budgets.isNotEmpty) {
        for (var budget in budgets) {
          weeklyBudgetExpenses[weekRange]![budget.goal] = 0;
        }
      }
      // Always initialize 'Other' even if there are other budgets
      weeklyBudgetExpenses[weekRange]!['Other'] = 0;
      weeklyBudgetExpenses[weekRange]!['Income'] = 0;
    }

    // 3. Group transactions by week range and budget/income (update existing values)
    for (var transaction in transactions) {
      if (transaction.date != null &&
          transaction.date!.month == activeMonth &&
          transaction.date!.year == activeYear) {
        DateTimeRange? weekRange = weeksOfMonth.firstWhere(
          (range) =>
              transaction.date!.isAfter(range.start) &&
              transaction.date!.isBefore(range.end),
          orElse: () => weeksOfMonth.last,
        );

        String categoryName;
        num transactionValue;

        if (transaction.spent) {
          categoryName = budgets.any((b) => b.goal == transaction.budget.goal)
              ? transaction.budget.goal
              : 'Other';
          transactionValue = -transaction.amount; // Expenses are negative
        } else {
          categoryName = 'Income';
          transactionValue = transaction.amount; // Income is positive
        }

        weeklyBudgetExpenses[weekRange]![categoryName] =
            (weeklyBudgetExpenses[weekRange]![categoryName]! +
                transactionValue);
      }
    }

    // 4. Calculate min, max, and interval for the y-axis
    num minValue = 0;
    num maxValue = 0;
    for (var weekExpenses in weeklyBudgetExpenses.values) {
      num weekTotal = weekExpenses.values.fold(0, (sum, value) => sum + value);
      minValue = min(minValue, weekTotal);
      maxValue = max(maxValue, weekTotal);
    }

    // Adjust min/max to ensure some padding around the data
    minValue = minValue * 1.1; // 10% padding below
    maxValue = maxValue * 1.1; // 10% padding above

    // Calculate a suitable interval
    num interval =
        (maxValue - minValue) / 5; // Divide the range into 5 intervals
    interval = (interval / 100).ceil() * 100; // Round up to the nearest 100

    // 5. Create ChartSeries
    List<ChartSeries<ChartData, String>> chartSeries = [];

    // Handle the case where there are no budgets at all OR there are 'Other' expenses
    if ((budgets.isEmpty && weeklyBudgetExpenses.isNotEmpty) ||
        weeklyBudgetExpenses.values
            .any((expenses) => expenses.containsKey('Other'))) {
      chartSeries.add(createSeriesForCategory(
        'Other',
        const Color.fromARGB(255, 128, 147, 241),
        weeksOfMonth,
        weeklyBudgetExpenses,
      ));
    }

    // Create series for each budget
    for (var budget in budgets) {
      chartSeries.add(
          createSeriesForBudget(budget, weeksOfMonth, weeklyBudgetExpenses));
    }

    // Always include the 'Income' series if there's any income
    if (weeklyBudgetExpenses.values
        .any((expenses) => expenses.containsKey('Income'))) {
      chartSeries.add(createSeriesForCategory(
        'Income',
        Colors.green,
        weeksOfMonth,
        weeklyBudgetExpenses,
      ));
    }

    return chartSeries;
  }

// Generalized function to create series for both budgets and income
  ChartSeries<ChartData, String> createSeriesForCategory(
      String categoryName,
      Color color,
      List<DateTimeRange> weeksOfMonth,
      Map<DateTimeRange, Map<String, num>> weeklyBudgetExpenses) {
    List<ChartData> chartData = [];
    for (var weekRange in weeksOfMonth) {
      num valueForCategory =
          weeklyBudgetExpenses[weekRange]![categoryName] ?? 0;
      String weekLabel =
          '${DateFormat('MMM d').format(weekRange.start)} - ${DateFormat('d').format(weekRange.end)}';
      chartData.add(ChartData(weekLabel, valueForCategory));
    }

    return StackedColumnSeries<ChartData, String>(
      dataSource: chartData,
      xValueMapper: (ChartData data, _) => data.x,
      yValueMapper: (ChartData data, _) => data.y,
      name: categoryName,
      color: color,
      animationDuration: 0, // Disable animation
    );
  }

  ChartSeries<ChartData, String> createSeriesForBudget(
      Budget budget,
      List<DateTimeRange> weeksOfMonth,
      Map<DateTimeRange, Map<String, num>> weeklyBudgetExpenses) {
    List<ChartData> chartData = [];
    for (var weekRange in weeksOfMonth) {
      num expenseForBudget = weeklyBudgetExpenses[weekRange]![budget.goal] ?? 0;
      String weekLabel =
          '${DateFormat('MMM d').format(weekRange.start)} - ${DateFormat('d').format(weekRange.end)}';
      chartData.add(ChartData(weekLabel, expenseForBudget));
    }

    return StackedColumnSeries<ChartData, String>(
      dataSource: chartData,
      xValueMapper: (ChartData data, _) => data.x,
      yValueMapper: (ChartData data, _) => data.y,
      name: budget.goal,
      color: budget.color,
    );
  }

  List<DateTimeRange> getWeeksOfMonth(int year, int month) {
    List<DateTimeRange> weeks = [];
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    DateTime currentWeekStart = firstDayOfMonth;
    while (currentWeekStart.isBefore(lastDayOfMonth)) {
      DateTime currentWeekEnd = currentWeekStart.add(const Duration(days: 6));
      if (currentWeekEnd.isAfter(lastDayOfMonth)) {
        currentWeekEnd = lastDayOfMonth;
      }
      weeks.add(DateTimeRange(start: currentWeekStart, end: currentWeekEnd));
      currentWeekStart = currentWeekEnd.add(const Duration(days: 1));
    }

    return weeks;
  }
}

Widget topBar(
    int activeMonth,
    int activeYear,
    VoidCallback onNextMonth,
    VoidCallback onLastMonth,
    num totalIncome,
    num totalIncomeChange,
    num totalExpenses,
    num totalExpensesChange,
    num totalCashFlowChange,
    bool isMonthlyView,
    VoidCallback onToggleView) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: onLastMonth,
                icon: const Icon(Icons.arrow_back_ios_new)),
            const SizedBox(width: 30),
            Column(
              children: [
                Text(
                  isMonthlyView
                      ? DateFormat.MMMM()
                          .format(DateTime(activeYear, activeMonth, 1))
                      : activeYear.toString(),
                  style: const TextStyle(
                    fontSize: 45,
                    color: Color.fromARGB(255, 255, 131, 90),
                  ),
                ),
                if (isMonthlyView) // Show year only in monthly view
                  Text(
                    DateTime(activeYear, activeMonth, 1).year.toString(),
                    style: const TextStyle(fontSize: 20),
                  )
              ],
            ),
            const SizedBox(width: 30),
            IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.arrow_forward_ios)),
          ],
        ),
      ),
      DropdownButton<String>(
        value: isMonthlyView ? 'Monthly' : 'Yearly',
        onChanged: (String? newValue) {
          if (newValue != null) {
            onToggleView();
          }
        },
        items: <String>['Monthly', 'Yearly']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
      financialSummaryRow(
        title: "Total Income:",
        value: totalIncome,
        changePercentage: totalIncomeChange,
      ),
      financialSummaryRow(
        title: "Total Expenses:",
        value: totalExpenses,
        changePercentage: totalExpensesChange,
        invertColors: true,
      ),
      financialSummaryRow(
        title: "Total Cashflow:",
        value: totalIncome - totalExpenses,
        changePercentage: totalCashFlowChange,
      ),
    ],
  );
}

Widget financialSummaryRow({
  required String title,
  required num value,
  required num changePercentage,
  bool invertColors = false,
}) {
  bool isPositiveChange = changePercentage >= 0;
  bool isValuePositive = value >= 0;

  Color valueColor =
      (isValuePositive && !invertColors) || (!isValuePositive && invertColors)
          ? Colors.green
          : Colors.red;
  Color changeColor =
      (isPositiveChange && !invertColors) || (!isPositiveChange && invertColors)
          ? Colors.green
          : Colors.red;

  return Padding(
    padding: const EdgeInsets.fromLTRB(12, 3, 12, 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        Row(
          children: [
            Text(
              formatFinancial(value) + "\$",
              style: TextStyle(
                fontSize: 16,
                color: valueColor,
              ),
            ),
            const SizedBox(width: 20),
            Row(
              children: [
                Text(
                  "${isPositiveChange ? '+' : ''}${changePercentage.toStringAsFixed(1) != 'NaN' ? changePercentage.toStringAsFixed(1) : "+0.0"}%",
                  style: TextStyle(
                    fontSize: 10,
                    color: changeColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "from last month",
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

String formatFinancial(num value) {
  if (value == 0) return "0.00";

  final suffixes = ['', 'K', 'M', 'B', 'T'];
  var magnitude = 0;
  while (value.abs() >= 1000) {
    magnitude += 1;
    value /= 1000;
  }
  return '${value.toStringAsFixed(2)}${suffixes[magnitude]}';
}

class ChartData {
  final String x;
  final num y;

  ChartData(this.x, this.y);
}
