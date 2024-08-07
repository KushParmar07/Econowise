import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multiselect/multiselect.dart';
import 'budget.dart';
import '../navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({
    super.key,
    this.currentBudget,
  });

  final Budget? currentBudget;

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _budgetTitleController = TextEditingController();
  final TextEditingController _budgetAmountController = TextEditingController();
  IconData _selectedIcon = Icons.shopping_cart;
  String budgetDescriptionText = 'How much would you like to spend on ';
  DateTime? _startSelectedDate = DateTime.now();
  DateTime? _endSelectedDate = DateTime.now().add(const Duration(days: 31));
  Color _selectedColor = const Color.fromARGB(255, 255, 131, 90);

  late List<Budget> currentBudgets = [];

  // List to hold common icons (you can customize this list)
  final List<IconData> _iconOptions = [
    Icons.shopping_cart,
    Icons.fastfood,
    Icons.local_gas_station,
    Icons.home,
    Icons.flight,
    Icons.pets,
    // Add more icons as needed
  ];

  Future<void> _pickIcon() async {
    IconData? selected = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select an icon'),
          content: SizedBox(
            // Use Container instead of SingleChildScrollView
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap:
                  true, // Important: Let GridView shrink to fit its content
              children: _iconOptions.map((icon) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop(icon);
                  },
                  child: Icon(
                    icon,
                    size: 32.0,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedIcon = selected;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? selectedDate,
      Function(DateTime?) updateSelectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      updateSelectedDate(picked);
    }
  }

  @override
  void initState() {
    context.read<SaveData>().categories.remove("");
    List<String> toDelete = [];
    super.initState();
    if (widget.currentBudget != null) {
      _budgetTitleController.text = widget.currentBudget!.goal;
      _budgetAmountController.text =
          widget.currentBudget!.budgetAmount.toString();
      _startSelectedDate = widget.currentBudget!.startDate;
      _endSelectedDate = widget.currentBudget!.endDate;
      _selectedIcon = widget.currentBudget!.icon;
      _selectedColor = widget.currentBudget!.color;
    }
  }

  void submit() async {
    if (_budgetTitleController.text != "" &&
        _budgetAmountController.text != "") {
      if (widget.currentBudget != null) {
        context.read<SaveData>().deleteBudget(widget.currentBudget ??
            Budget("Placeholder", 100, DateTime.now(), DateTime.now(),
                Icons.abc, Colors.blue));
      }
      context.read<SaveData>().addBudget(Budget(
          _budgetTitleController.text,
          double.parse(_budgetAmountController.text),
          _startSelectedDate,
          _endSelectedDate,
          _selectedIcon,
          _selectedColor));

      context.read<SaveData>().updateTransactions(context
          .read<SaveData>()
          .budgets[context.read<SaveData>().budgets.length - 1]);
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
    dispose();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const MenuSelecter(index: 0)));
    context.read<SaveData>().categories.insert(0, "");
  }

  void pickColor(BuildContext context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Pick A Color"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildColorPicker(),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('SELECT'))
            ],
          )));

  Widget buildColorPicker() => BlockPicker(
          pickerColor: _selectedColor,
          onColorChanged: (color) => setState(() {
                _selectedColor = color;
              }),
          availableColors: const [
            Colors.red,
            Colors.pink,
            Color.fromARGB(255, 179, 136, 235),
            Colors.deepPurple,
            Colors.indigo,
            Color.fromARGB(255, 128, 147, 241),
            Colors.lightBlue,
            Colors.cyan,
            Colors.teal,
            Colors.green,
            Colors.lightGreen,
            Colors.lime,
            Colors.yellow,
            Colors.amber,
            Color.fromARGB(255, 255, 131, 90),
            Colors.deepOrange,
            Colors.brown,
            Colors.grey,
            Colors.blueGrey,
            Colors.black,
          ]);

  @override
  void dispose() {
    super.dispose();
    _budgetTitleController.dispose();
    _budgetAmountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Set your budget',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 32)),
          elevation: 0,
          leading:
              IconButton(onPressed: back, icon: const Icon(Icons.arrow_back)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Color.fromARGB(255, 255, 131, 90),
                  Color.fromARGB(255, 229, 176, 158)
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
                    children: <Widget>[
                      const Text(
                        'Set amount budget',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        budgetDescriptionText,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      budgetAmountSelector(),

                      const SizedBox(height: 20),
                      const Text(
                        'Set Starting Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      grayOutline(selectDateDisplay(_startSelectedDate), 30,
                          onTap: () => _selectDate(context, _startSelectedDate,
                                  (newDate) {
                                setState(() {
                                  _startSelectedDate = newDate;
                                });
                              })),

                      const SizedBox(height: 8),
                      const Text(
                        'Set Ending Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      grayOutline(selectDateDisplay(_endSelectedDate), 30,
                          onTap: () =>
                              _selectDate(context, _endSelectedDate, (newDate) {
                                setState(() {
                                  _endSelectedDate = newDate;
                                });
                              })),

                      const SizedBox(height: 8),
                      const Text(
                        'Select Colour',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      grayOutline(colourSelectorDisplay(context), 60),
                      const SizedBox(height: 10),
                      // Create Budget Button
                      const SizedBox(height: 40),
                      submitBudgetButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]));
  }

  Center submitBudgetButton() {
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
              child: Text(
                widget.currentBudget == null ? 'Create Budget' : 'Save Budget',
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

  Row colourSelectorDisplay(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Expanded(
            child: Text(
          "Color:",
          style: TextStyle(fontSize: 20),
        )),
        FilledButton(
          onPressed: () => {pickColor(context)},
          style: FilledButton.styleFrom(backgroundColor: _selectedColor),
          child: const SizedBox(
            height: 40,
            width: 70,
          ),
        )
      ],
    );
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

  Row selectDateDisplay(DateTime? dateObject) {
    return Row(
      children: [
        Expanded(
          child: Text(
            dateObject == null
                ? DateTime.now().toString().split(" ")[0]
                : dateObject.toString().split(" ")[0],
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const Icon(Icons.calendar_today, color: Colors.grey),
      ],
    );
  }

  SizedBox budgetAmountSelector() {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: _budgetAmountController,
        decoration: InputDecoration(
          hintText: '\$0.00',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100]!,
          suffixText: 'Budget amount',
          suffixStyle: const TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(fontSize: 24),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Container topBackground() {
    return Container(
      height: 200, // Adjust height as needed
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(100),
            bottomRight: Radius.circular(100)),
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 131, 90),
            Color.fromARGB(255, 229, 176, 158)
          ], // Orange shades
        ),
      ),
      child: topSelector(),
    );
  }

  Column topSelector() {
    return Column(
      children: [
        Container(height: 20),
        Center(
          child: InkWell(
            onTap: _pickIcon,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedIcon,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 300, // Width of the TextField
            height: 48, // Height of the TextField
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: TextField(
              textAlign: TextAlign.center,
              controller: _budgetTitleController,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  hintText: 'Budget Title',
                  suffixIcon: Icon(Icons.edit)),
              style: const TextStyle(fontSize: 20),
              onChanged: (value) {
                setState(() {
                  budgetDescriptionText =
                      'How much would you like to spend on $value?';
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
