import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:econowise/transaction_files/transaction.dart';
import 'package:econowise/save_data.dart';
import 'package:econowise/budget_files/budget.dart';

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
                toggleView)
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

      if (previousYearIncome == 0) {
        return 0;
      }

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

      if (previousYearExpenses == 0) {
        return 0;
      }

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

      if (previousMonthCashflow == 0) {
        return 0;
      }

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

      if (previousYearCashflow == 0) {
        return 0;
      }

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
    padding: const EdgeInsets.fromLTRB(30, 3, 50, 3),
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
              "${value.toStringAsFixed(2)}\$",
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
