import 'package:econowise/budget_files/budget.dart';
import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'transaction.dart';
import '../navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'expanded_dropdown.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({
    super.key,
    this.currentTransaction,
  });

  final Transaction? currentTransaction;

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _transactionTitleController =
      TextEditingController();
  final TextEditingController _transactionAmountController =
      TextEditingController();
  bool spent = false;
  String transactionDescriptionText = 'How much did you spend on ';
  DateTime? _selectedDate = DateTime.now();
  late Budget selectedBudget;
  final TextEditingController categoryTitle = TextEditingController();

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentTransaction != null) {
      _transactionTitleController.text = widget.currentTransaction!.title;
      _transactionAmountController.text =
          widget.currentTransaction!.amount.toString();
      _selectedDate = widget.currentTransaction!.date;
      spent = widget.currentTransaction!.spent;
      selectedBudget = widget.currentTransaction!.budget;
    }

    if (widget.currentTransaction == null) {
      if (spent) {
        selectedBudget = Budget("sample", 0, DateTime.now(), DateTime.now(),
            Icons.money_off, Colors.red, 0);
      } else {
        selectedBudget = Budget("sample", 0, DateTime.now(), DateTime.now(),
            Icons.attach_money, Colors.green, 0);
      }
    }
  }

  void submit() {
    if (_transactionTitleController.text != "" &&
        _transactionAmountController.text != "") {
      if (widget.currentTransaction != null) {
        context.read<SaveData>().deleteTransaction(widget.currentTransaction ??
            Transaction(
                "Placeholder",
                500,
                spent,
                DateTime.now(),
                Budget(
                    "sample",
                    0,
                    DateTime.now(),
                    DateTime.now(),
                    Icons.attach_money,
                    const Color.fromARGB(255, 128, 147, 241),
                    0)));
      }
      if (spent) {
        if (context.read<SaveData>().budgets.isEmpty) {
          selectedBudget = Budget("sample", 0, DateTime.now(), DateTime.now(),
              Icons.money_off, Colors.red, 0);
        }
      } else {
        selectedBudget = Budget("sample", 0, DateTime.now(), DateTime.now(),
            Icons.attach_money, Colors.green, 0);
      }
      context.read<SaveData>().addTransaction(Transaction(
          _transactionTitleController.text,
          double.parse(_transactionAmountController.text),
          spent,
          _selectedDate,
          selectedBudget));

      if (context.read<SaveData>().budgets.isNotEmpty) {
        for (var budget in context.read<SaveData>().budgets) {
          context.read<SaveData>().updateTransactions(budget);

          if (budget.warningAmount > 0) {
            if (budget.totalUsed >= budget.warningAmount && spent) {
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
      }
      context.read<SaveData>().saveData();
      back();
    } else {
      Fluttertoast.showToast(
          msg: "One or more required fields have been left blank",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20);
    }
  }

  void back() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const MenuSelecter(index: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Transaction',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 32)),
          elevation: 0,
          leading:
              IconButton(onPressed: back, icon: const Icon(Icons.arrow_back)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                  context.read<SaveData>().primaryColor,
                  context.read<SaveData>().primaryColor.withAlpha(110)
                ])),
          ),
          centerTitle: true,
        ),
        body: Stack(children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: [
                topBackground(),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      transactionAmountSelector(),
                      const SizedBox(height: 20),
                      const Text(
                        'Was This An Expense?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      grayOutline(transactionExpenseController(), 50),
                      const SizedBox(height: 20),
                      const Text(
                        'Set Transaction Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      grayOutline(dateSelectDisplay(), 30,
                          onTap: () => _selectStartDate(context)),
                      const SizedBox(height: 20),
                      spent
                          ? const Text(
                              "Select Budget Affected",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 20,
                      ),
                      spent
                          ? grayOutline(categorySelectorDisplay(context), 50)
                          : const SizedBox(),
                      const SizedBox(height: 40),
                      submitTransactionButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]));
  }

  Center submitTransactionButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            submit();
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  context.read<SaveData>().primaryColor,
                  context.read<SaveData>().secondaryColor
                ],
              ),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              alignment: Alignment.center,
              child: Text(
                widget.currentTransaction == null
                    ? 'Create Transaction'
                    : 'Save Transaction',
                style: const TextStyle(
                  fontSize: 20,
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

  Flexible categorySelectorDisplay(BuildContext context) {
    return Flexible(
      child: Consumer<SaveData>(
        builder: (context, saveData, _) {
          return ExpandedDropdownMenu(
            initialSelection: selectedBudget,
            controller: categoryTitle,
            onSelected: (Budget? value) {
              setState(() {
                selectedBudget = value!;
              });
            },
            dropdownMenuEntries:
                saveData.budgets.map<DropdownMenuEntry<Budget>>((Budget value) {
              return DropdownMenuEntry<Budget>(
                  value: value,
                  label: value.goal,
                  leadingIcon: Icon(value.icon, color: value.color));
            }).toList(),
          );
        },
      ),
    );
  }

  Row dateSelectDisplay() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _selectedDate == null
                ? DateTime.now().toString().split(" ")[0]
                : _selectedDate!.toString().split(" ")[0],
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const Icon(Icons.calendar_today, color: Colors.grey),
      ],
    );
  }

  Row transactionExpenseController() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Expense",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Switch(
            value: spent,
            activeColor: Colors.red,
            onChanged: (bool value) {
              {
                setState(() {
                  spent = value;
                  selectedBudget = Budget("sample", 0, DateTime.now(),
                      DateTime.now(), Icons.money_off, Colors.red, 0);
                });
              }
            }),
      ],
    );
  }

  Column transactionAmountSelector() {
    return Column(
      children: [
        const Text(
          'Set transaction amount',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          transactionDescriptionText,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: TextField(
            maxLength: 12,
            controller: _transactionAmountController,
            decoration: InputDecoration(
              hintText: '\$0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100]!,
              suffixText: 'Transaction amount',
              suffixStyle: const TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(fontSize: 24),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Container topBackground() {
    return Container(
      height: 100, // Adjust height as needed
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(100),
            bottomRight: Radius.circular(100)),
        gradient: LinearGradient(
          colors: [
            context.read<SaveData>().primaryColor,
            context.read<SaveData>().primaryColor.withAlpha(110)
          ], // Orange shades
        ),
      ),
      child: Center(
        child: Container(
          width: 300, // Width of the TextField
          height: 48, // Height of the TextField
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(0, 245, 245, 245),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: TextField(
            textAlign: TextAlign.center,
            controller: _transactionTitleController,
            decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                hintText: 'Transaction Title',
                suffixIcon: Icon(Icons.edit)),
            style: const TextStyle(fontSize: 20),
            onChanged: (value) {
              setState(() {
                transactionDescriptionText =
                    'How much would you like to spend on $value?';
              });
            },
          ),
        ),
      ),
    );
  }
}

SizedBox grayOutline(Widget inside, double height,
    {Future<void> Function()? onTap}) {
  return SizedBox(
    height: height,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100]!,
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: inside,
      ),
    ),
  );
}
