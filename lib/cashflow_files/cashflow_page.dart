import 'dart:math';
import 'package:collection/collection.dart';
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

  bool showTooltip = false;
  String? tooltipText;
  Offset? tooltipPosition;

  String? selectedCategoryName;
  num? selectedCategoryValue;
  num? categoryTotal; // Total for the selected category in the active period
  Budget? selectedBudget;

  @override
  void initState() {
    super.initState();
    activeMonth = context.read<SaveData>().activeMonth;
    activeYear = context.read<SaveData>().activeYear;
    isMonthlyView = context.read<SaveData>().isMonthlyView;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Center(
                    child: Text("Spending Analysis",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600))),
                DropdownButton<String>(
                  value: isMonthlyView ? 'Monthly' : 'Yearly',
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      toggleView();
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
              ],
            ),
            Consumer<SaveData>(
              builder: (context, saveData, _) {
                final transactions = saveData.transactions;
                final budgets = saveData.budgets;
                final chartSeries =
                    getChartSeriesData().cast<CartesianSeries>();
                final axisRange = calculateYAxisRange(transactions, budgets);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SfCartesianChart(
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
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      title: const LegendTitle(
                        text: 'Legend',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor:
                          Colors.grey[100], // Light gray background
                      borderWidth: 1, // Border width
                      borderColor: Colors.grey[300], // Border color
                    ),
                  ),
                );
              },
            ),
            infoSection()
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
      context.read<SaveData>().activeMonth = activeMonth;
      context.read<SaveData>().activeYear = activeYear;
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
      context.read<SaveData>().activeMonth = activeMonth;
      context.read<SaveData>().activeYear = activeYear;
    });
  }

  void toggleView() {
    setState(() {
      isMonthlyView = !isMonthlyView;
      context.read<SaveData>().isMonthlyView = isMonthlyView;

      selectedCategoryName = null;
      selectedCategoryValue = null;
      categoryTotal = null;
      selectedBudget = null;
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

  num getTotalForCategoryInMonth(String categoryName, int month, int year) {
    num total = 0;
    for (var transaction in context.read<SaveData>().transactions) {
      if (transaction.date != null &&
          transaction.date!.month == month &&
          transaction.date!.year == year) {
        if ((transaction.spent &&
                (transaction.budget?.goal == categoryName ||
                    (categoryName == 'Other Expenses' &&
                        !context.read<SaveData>().budgets.any(
                            (b) => b.goal == transaction.budget?.goal)))) ||
            (!transaction.spent && categoryName == 'Income')) {
          total += transaction.spent ? -transaction.amount : transaction.amount;
        }
      }
    }
    return total;
  }

  num getTotalForCategoryInYear(String categoryName, int year) {
    num total = 0;
    for (var transaction in context.read<SaveData>().transactions) {
      if (transaction.date != null && transaction.date!.year == year) {
        if ((transaction.spent &&
                (transaction.budget?.goal == categoryName ||
                    (categoryName == 'Other Expenses' &&
                        !context.read<SaveData>().budgets.any(
                            (b) => b.goal == transaction.budget?.goal)))) ||
            (!transaction.spent && categoryName == 'Income')) {
          total += transaction.spent ? -transaction.amount : transaction.amount;
        }
      }
    }
    return total;
  }

  (double, double, double) calculateYAxisRange(
      List<Transaction> transactions, List<Budget> budgets) {
    double range = 0;

    if (isMonthlyView) {
      // 1. Get all weeks of the active month
      List<DateTimeRange> weeksOfMonth =
          getWeeksOfMonth(activeYear, activeMonth);

      // 2. Initialize weeklyTotals with all weeks
      Map<DateTimeRange, double> weeklyTotals = {};
      for (var week in weeksOfMonth) {
        weeklyTotals[week] = 0;
      }

      // 3. Accumulate values for each week and category/budget
      Map<DateTimeRange, Map<String, num>> weeklyCategoryTotals = {};
      for (var transaction in transactions) {
        if (transaction.date != null &&
            transaction.date!.month == activeMonth &&
            transaction.date!.year == activeYear) {
          DateTimeRange? weekRange = weeksOfMonth.firstWhereOrNull(
            (range) =>
                transaction.date!.isAfter(range.start) &&
                transaction.date!.isBefore(range.end),
          );

          if (weekRange != null) {
            String categoryName = transaction.spent
                ? (transaction.budget != null &&
                        budgets.any((b) => b.goal == transaction.budget!.goal)
                    ? transaction.budget!.goal
                    : 'Other Expenses')
                : 'Income';
            double transactionValue =
                transaction.spent ? -transaction.amount : transaction.amount;

            // Accumulate values for each category within the week
            weeklyCategoryTotals[weekRange] ??= {};
            weeklyCategoryTotals[weekRange]![categoryName] =
                (weeklyCategoryTotals[weekRange]![categoryName] ?? 0) +
                    transactionValue;
          }
        }
      }

      // 4. Find the maximum absolute sum of values for each week
      for (var week in weeksOfMonth) {
        double weekTotal = 0;
        for (var categoryTotal in weeklyCategoryTotals[week]?.values ?? []) {
          categoryTotal = categoryTotal as num;
          weekTotal += categoryTotal; // Sum the category totals for the week
        }
        range = max(range, weekTotal.abs()); // Update range based on the total
      }
    } else {
      // Yearly view
      // 1. Get all months of the active year
      List<int> monthsOfYear = List.generate(12, (index) => index + 1);

      // 2. Initialize monthlyTotals with all months
      Map<int, double> monthlyTotals = {};
      for (var month in monthsOfYear) {
        monthlyTotals[month] = 0;
      }

      // 3. Accumulate values for each month and category/budget
      Map<int, Map<String, num>> monthlyCategoryTotals = {};
      for (var transaction in transactions) {
        if (transaction.date != null && transaction.date!.year == activeYear) {
          int month = transaction.date!.month;
          String categoryName = transaction.spent
              ? (transaction.budget != null &&
                      budgets.any((b) => b.goal == transaction.budget!.goal)
                  ? transaction.budget!.goal
                  : 'Other Expenses')
              : 'Income';
          double transactionValue =
              transaction.spent ? -transaction.amount : transaction.amount;

          // Accumulate values for each category within the month
          monthlyCategoryTotals[month] ??= {};
          monthlyCategoryTotals[month]![categoryName] =
              (monthlyCategoryTotals[month]![categoryName] ?? 0) +
                  transactionValue;
        }
      }

      // 4. Find the maximum absolute sum of incomes and expenses separately for each month
      for (var month in monthsOfYear) {
        double monthIncomeTotal = 0;
        double monthExpenseTotal = 0;

        for (var categoryTotal in monthlyCategoryTotals[month]?.values ?? []) {
          categoryTotal = categoryTotal as double;
          if (categoryTotal > 0) {
            // Income
            monthIncomeTotal += categoryTotal;
          } else {
            // Expense
            monthExpenseTotal += categoryTotal.abs();
          }
        }

        // Take the maximum of income and expense totals for the month
        range = max(range, max(monthIncomeTotal, monthExpenseTotal));
      }
    }

    // Handle the case where there are no transactions (after filtering)
    if (range == 0) {
      range = 500; // Or any other suitable default value
    }

    // Ensure 0 is in the middle and scale accordingly
    range = max(range, 500);

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
    double minValue = -range; // Start with the negative of the calculated range
    double maxValue = range;

    if (minValue > 0) {
      minValue = 0; // If minValue is positive, set it to 0
    } else if (maxValue < 0) {
      maxValue = 0; // If maxValue is negative, set it to 0
    }

    // Round up maxValue and round down minValue to the nearest interval mark
    maxValue = (maxValue / interval).ceil() * interval;
    minValue = (minValue / interval).floor() * interval;

    // Recalculate interval if necessary
    interval = (maxValue - minValue) / 10;
    interval = (interval / 100).ceil() * 100;

    return (-range, range, interval);
  }

  List<ChartSeries<ChartData, String>> getChartSeriesData() {
    List<Transaction> transactions = context.read<SaveData>().transactions;
    List<Budget> budgets = context.read<SaveData>().budgets;

    if (isMonthlyView) {
      // 1. Get all weeks of the active month
      List<DateTimeRange> weeksOfMonth =
          getWeeksOfMonth(activeYear, activeMonth);

      // 2. Initialize weeklyBudgetExpenses with all weeks and budgets (or 'Other Expenses')
      Map<DateTimeRange, Map<String, num>> weeklyBudgetExpenses = {};
      for (var weekRange in weeksOfMonth) {
        weeklyBudgetExpenses[weekRange] = {};
        if (budgets.isNotEmpty) {
          for (var budget in budgets) {
            weeklyBudgetExpenses[weekRange]![budget.goal] = 0;
          }
        }
        // Always initialize 'Other Expenses' even if there are other budgets
        weeklyBudgetExpenses[weekRange]!['Other Expenses'] = 0;
        weeklyBudgetExpenses[weekRange]!['Income'] = 0;
      }

      // 3. Group transactions by week range and budget/income (update existing values)
      for (var transaction in transactions) {
        if (transaction.date != null &&
            transaction.date!.month == activeMonth &&
            transaction.date!.year == activeYear) {
          DateTimeRange? weekRange = weeksOfMonth.firstWhereOrNull(
            (range) =>
                transaction.date!
                    .isAfter(range.start.subtract(const Duration(days: 1))) &&
                transaction.date!
                    .isBefore(range.end.add(const Duration(days: 1))),
          );

          String categoryName;
          num transactionValue;

          if (transaction.spent) {
            categoryName = budgets.any((b) => b.goal == transaction.budget.goal)
                ? transaction.budget.goal
                : 'Other Expenses';
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
        num weekTotal =
            weekExpenses.values.fold(0, (sum, value) => sum + value);
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

      // Handle the case where there are no budgets at all OR there are 'Other Expenses' expenses
      if ((budgets.isEmpty && weeklyBudgetExpenses.isNotEmpty) ||
          weeklyBudgetExpenses.values
              .any((expenses) => expenses.containsKey('Other Expenses'))) {
        chartSeries.add(createSeriesForCategory(
          'Other Expenses',
          Colors.red,
          weeksOfMonth,
          weeklyBudgetExpenses,
        ));
      }

      // Create series for each budget
      for (var budget in budgets) {
        chartSeries.add(createSeriesForBudget(
            budget, weeksOfMonth, weeklyBudgetExpenses, context));
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

      List<ChartSeries<ChartData, String>> filteredChartSeries = [];
      for (var series in chartSeries) {
        num totalValue = 0;
        for (var data in series.dataSource as List<ChartData>) {
          totalValue += data.y;
        }
        if (totalValue != 0) {
          filteredChartSeries.add(series);
        }
      }

      return filteredChartSeries;
    } else {
      // Yearly view
      // 1. Get all months of the active year
      List<int> monthsOfYear = List.generate(12, (index) => index + 1);

      // 2. Initialize monthlyBudgetExpenses with all months and budgets (or 'Other Expenses')
      Map<int, Map<String, num>> monthlyBudgetExpenses = {};
      for (var month in monthsOfYear) {
        monthlyBudgetExpenses[month] = {};
        if (budgets.isNotEmpty) {
          for (var budget in budgets) {
            monthlyBudgetExpenses[month]![budget.goal] = 0;
          }
        }
        // Always initialize 'Other Expenses' even if there are other budgets
        monthlyBudgetExpenses[month]!['Other Expenses'] = 0;
        monthlyBudgetExpenses[month]!['Income'] = 0;
      }

      // 3. Group transactions by month and budget/income (update existing values)
      for (var transaction in transactions) {
        if (transaction.date != null && transaction.date!.year == activeYear) {
          int month = transaction.date!.month;

          String categoryName;
          num transactionValue;

          if (transaction.spent) {
            categoryName = budgets.any((b) => b.goal == transaction.budget.goal)
                ? transaction.budget.goal
                : 'Other Expenses';
            transactionValue = -transaction.amount; // Expenses are negative
          } else {
            categoryName = 'Income';
            transactionValue = transaction.amount; // Income is positive
          }

          monthlyBudgetExpenses[month]![categoryName] =
              (monthlyBudgetExpenses[month]![categoryName]! + transactionValue);
        }
      }

      // 4. Calculate min, max, and interval for the y-axis
      num minValue = 0;
      num maxValue = 0;
      for (var monthExpenses in monthlyBudgetExpenses.values) {
        num monthTotal =
            monthExpenses.values.fold(0, (sum, value) => sum + value);
        minValue = min(minValue, monthTotal);
        maxValue = max(maxValue, monthTotal);
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

      // Handle the case where there are no budgets at all OR there are 'Other Expenses' expenses
      if ((budgets.isEmpty && monthlyBudgetExpenses.isNotEmpty) ||
          monthlyBudgetExpenses.values
              .any((expenses) => expenses.containsKey('Other Expenses'))) {
        chartSeries.add(createSeriesForCategory(
          'Other Expenses',
          Colors.red,
          monthsOfYear,
          monthlyBudgetExpenses,
        ));
      }

      // Create series for each budget
      for (var budget in budgets) {
        chartSeries.add(createSeriesForBudget(
            budget, monthsOfYear, monthlyBudgetExpenses, context));
      }

      // Always include the 'Income' series if there's any income
      if (monthlyBudgetExpenses.values
          .any((expenses) => expenses.containsKey('Income'))) {
        chartSeries.add(createSeriesForCategory(
          'Income',
          Colors.green,
          monthsOfYear,
          monthlyBudgetExpenses,
        ));
      }
      List<ChartSeries<ChartData, String>> filteredChartSeries = [];
      for (var series in chartSeries) {
        num totalValue = 0;
        for (var data in series.dataSource as List<ChartData>) {
          totalValue += data.y;
        }
        if (totalValue != 0) {
          filteredChartSeries.add(series);
        }
      }

      return filteredChartSeries;
    }
  }

// Generalized function to create series for both budgets and income
  ChartSeries<ChartData, String> createSeriesForCategory(
      String categoryName,
      Color color,
      List<dynamic> timePeriods, // Can be weeksOfMonth or monthsOfYear
      Map<dynamic, Map<String, num>> budgetExpenses) {
    List<ChartData> chartData = [];
    for (var timePeriod in timePeriods) {
      num valueForCategory = budgetExpenses[timePeriod]![categoryName] ?? 0;
      String timePeriodLabel = isMonthlyView
          ? '${DateFormat('MMM d').format((timePeriod as DateTimeRange).start)} - ${DateFormat('d').format((timePeriod).end)}'
          : DateFormat.MMM().format(DateTime(activeYear, timePeriod as int, 1));
      chartData.add(ChartData(timePeriodLabel, valueForCategory));
    }

    return StackedColumnSeries<ChartData, String>(
      legendIconType: LegendIconType.rectangle,
      dataSource: chartData,
      xValueMapper: (ChartData data, _) => data.x,
      yValueMapper: (ChartData data, _) => data.y,
      name: categoryName,
      color: color,
      animationDuration: 0,
      onPointTap: (ChartPointDetails args) {
        if (args.pointIndex != null) {
          final ChartData data = chartData[args.pointIndex!];

          // Find the total for the selected category
          num categoryTotal = isMonthlyView
              ? getTotalForCategoryInMonth(
                  categoryName, activeMonth, activeYear)
              : getTotalForCategoryInYear(categoryName, activeYear);

          // Find the budget if the category matches a budget goal
          Budget? budget = context
              .read<SaveData>()
              .budgets
              .firstWhereOrNull((b) => b.goal == categoryName);

          setState(() {
            selectedCategoryName = categoryName;
            selectedCategoryValue = data.y;
            this.categoryTotal = categoryTotal;
            selectedBudget = budget;
          });
        }
      },
    );
  }

  ChartSeries<ChartData, String> createSeriesForBudget(
      Budget budget,
      List<dynamic> timePeriods, // Can be weeksOfMonth or monthsOfYear
      Map<dynamic, Map<String, num>> budgetExpenses,
      BuildContext context) {
    List<ChartData> chartData = [];
    for (var timePeriod in timePeriods) {
      num expenseForBudget = budgetExpenses[timePeriod]![budget.goal] ?? 0;
      String timePeriodLabel = isMonthlyView
          ? '${DateFormat('MMM d').format((timePeriod as DateTimeRange).start)} - ${DateFormat('d').format((timePeriod).end)}'
          : DateFormat.MMM().format(DateTime(activeYear, timePeriod as int, 1));
      chartData.add(ChartData(timePeriodLabel, expenseForBudget));
    }

    return StackedColumnSeries<ChartData, String>(
      legendIconType: LegendIconType.rectangle,
      dataSource: chartData,
      xValueMapper: (ChartData data, _) => data.x,
      yValueMapper: (ChartData data, _) => data.y,
      name: budget.goal,
      color: budget.color,
      animationDuration: 0,
      onPointTap: (ChartPointDetails args) {
        if (args.pointIndex != null) {
          final ChartData data = chartData[args.pointIndex!];

          // Find the total for the selected budget
          num categoryTotal = isMonthlyView
              ? getTotalForCategoryInMonth(budget.goal, activeMonth, activeYear)
              : getTotalForCategoryInYear(budget.goal, activeYear);

          setState(() {
            selectedCategoryName = budget.goal;
            selectedCategoryValue = data.y;
            this.categoryTotal = categoryTotal;
            selectedBudget = budget;
          });
        }
      },
    );
  }

  Widget infoSection() {
    return Column(
      children: [
        const Center(
            child: Text(
          "Info",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 200),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: selectedCategoryName != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            selectedCategoryName!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Amount: \$${selectedCategoryValue!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedCategoryValue! >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Total "${selectedCategoryName!}" for ${isMonthlyView ? 'Month' : 'Year'}: \$${categoryTotal!.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (selectedBudget != null) ...[
                          const SizedBox(height: 15),
                          LinearProgressIndicator(
                            value: selectedBudget!.totalUsed /
                                selectedBudget!.budgetAmount,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                selectedBudget!.color),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Used: \$${selectedBudget!.totalUsed.toStringAsFixed(2)} / \$${selectedBudget!.budgetAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Remaining: \$${(selectedBudget!.budgetAmount - selectedBudget!.totalUsed).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    )
                  : const Center(
                      child: Text(
                        'Click A Bar To Display Info',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
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
              "${formatFinancial(value)}\$",
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
