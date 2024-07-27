import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'budget.dart';
import 'navigation_bar.dart';
import 'package:provider/provider.dart';

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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startSelectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startSelectedDate) {
      setState(() {
        _startSelectedDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endSelectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endSelectedDate) {
      setState(() {
        _endSelectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentBudget != null) {
      _budgetTitleController.text = widget.currentBudget!.goal;
      _budgetAmountController.text =
          widget.currentBudget!.budgetAmount.toString();
      _startSelectedDate = widget.currentBudget!.startDate;
      _endSelectedDate = widget.currentBudget!.endDate;
      _selectedIcon = widget.currentBudget!.icon;
    }
  }

  void submit() {
    if (widget.currentBudget == null) {
      if (_budgetTitleController.text != "" &&
          _budgetAmountController.text != "") {
        context.read<SaveData>().addBudget(Budget(
            _budgetTitleController.text,
            int.parse(_budgetAmountController.text),
            _startSelectedDate,
            _endSelectedDate,
            _selectedIcon));
      }
    } else {
      if (_budgetTitleController.text != "" &&
          _budgetAmountController.text != "") {
        context.read<SaveData>().deleteBudget(widget.currentBudget ??
            Budget(
                "Placeholder", 100, DateTime.now(), DateTime.now(), Icons.abc));
        context.read<SaveData>().addBudget(Budget(
            _budgetTitleController.text,
            int.parse(_budgetAmountController.text),
            _startSelectedDate,
            _endSelectedDate,
            _selectedIcon));
      }
    }

    back();
  }

  void back() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const MenuSelecter(index: 0)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor:
              const Color(0xFFF59E0B), // Make the AppBar transparent
          title: Text('Set your budget',
              style: TextStyle(
                  color: Colors.purple[400],
                  fontWeight: FontWeight.w600,
                  fontSize: 32)),
          elevation: 0,
          leading:
              IconButton(onPressed: back, icon: const Icon(Icons.arrow_back)),
        ),
        body: Stack(children: <Widget>[
          // Background with curved shape (CustomClipper)
          ClipPath(
            clipper: BackgroundClipper(),
            child: Container(
              height: 250, // Adjust height as needed
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF59E0B),
                    Color(0xFFFFEDD5)
                  ], // Orange shades
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // Icon in a purple circle (Moved above)
                  Center(
                    child: InkWell(
                      onTap: _pickIcon,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6750A4), // Purple background
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
                  // Category TextField (Moved below)
                  Center(
                    child: Container(
                      width: 200, // Width of the TextField
                      height: 48, // Height of the TextField
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 245, 245, 245),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _budgetTitleController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
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

                  const SizedBox(height: 70),

                  // Budget Amount Field (Left-aligned labels)
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
                  SizedBox(
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
                  ),

                  // Optional Date Field (Date Picker)
                  const SizedBox(height: 20),
                  const Text(
                    'Set Starting Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 30,
                    child: InkWell(
                      onTap: () => _selectStartDate(context),
                      borderRadius: BorderRadius.circular(30.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100]!,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _startSelectedDate == null
                                    ? DateTime.now().toString().split(" ")[0]
                                    : _startSelectedDate!
                                        .toString()
                                        .split(" ")[0],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const Icon(Icons.calendar_today,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Set Ending Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 30,
                    child: InkWell(
                      onTap: () => _selectEndDate(context),
                      borderRadius: BorderRadius.circular(30.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100]!,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _endSelectedDate == null
                                    ? DateTime.now().toString().split(" ")[0]
                                    : _endSelectedDate!
                                        .toString()
                                        .split(" ")[0],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const Icon(Icons.calendar_today,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Create Budget Button
                  const SizedBox(height: 40),
                  Center(
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
                              colors: [Colors.orange, Color(0xFF6750A4)],
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 60),
                            alignment: Alignment.center,
                            child: Text(
                              widget.currentBudget == null
                                  ? 'Create Budget'
                                  : 'Save Budget',
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
                  ),
                ],
              ),
            ),
          ),
        ]));
  }
}

class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
