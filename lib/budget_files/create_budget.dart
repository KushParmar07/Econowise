import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<String> selectedCategories = [];

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
      selectedCategories = widget.currentBudget!.categories;

      if (selectedCategories.isNotEmpty) {
        for (var category in selectedCategories) {
          if (!context.read<SaveData>().categories.contains(category)) {
            toDelete.add(category);
          }
        }
      }
    }
    for (var categoryToDelete in toDelete) {
      selectedCategories.remove(categoryToDelete);
    }
  }

  void submit() async {
    if (_budgetTitleController.text != "" &&
        _budgetAmountController.text != "") {
      if (widget.currentBudget != null) {
        context.read<SaveData>().deleteBudget(widget.currentBudget ??
            Budget("Placeholder", 100, DateTime.now(), DateTime.now(),
                Icons.abc, Colors.blue, selectedCategories));
      }
      context.read<SaveData>().addBudget(Budget(
          _budgetTitleController.text,
          double.parse(_budgetAmountController.text),
          _startSelectedDate,
          _endSelectedDate,
          _selectedIcon,
          _selectedColor,
          selectedCategories));

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

  Future<void> modifyCategories() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Categories'),
          content: StatefulBuilder(builder: (context, setState) {
            return Container(
              width: double.maxFinite,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: context.read<SaveData>().categories.length + 1,
                  itemBuilder: (BuildContext context, index) {
                    if (index == 0) {
                      return ElevatedButton(
                          onPressed: createCategory,
                          child: Text("New Category"));
                    } else {
                      var category =
                          context.read<SaveData>().categories[index - 1];
                      return Card(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(category),
                            IconButton(
                                onPressed: () => {
                                      setState(
                                        () {
                                          context
                                              .read<SaveData>()
                                              .deleteCategory(category);
                                          if (selectedCategories
                                              .contains(category)) {
                                            selectedCategories.remove(category);
                                          }
                                        },
                                      )
                                    },
                                icon: const Icon(Icons.delete))
                          ],
                        ),
                      );
                    }
                  }),
            );
          }),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createCategory() async {
    TextEditingController categoryTitle = TextEditingController();
    Navigator.of(context).pop();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create A Category'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(controller: categoryTitle),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                setState(() {
                  context.read<SaveData>().addCategory(categoryTitle.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
                Container(
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
                  child: Column(
                    children: [
                      Container(height: 20),
                      Center(
                        child: InkWell(
                          onTap: _pickIcon,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 179, 136, 235),
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: <Widget>[
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _startSelectedDate == null
                                        ? DateTime.now()
                                            .toString()
                                            .split(" ")[0]
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _endSelectedDate == null
                                        ? DateTime.now()
                                            .toString()
                                            .split(" ")[0]
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

                      const SizedBox(height: 8),
                      const Text(
                        'Select Colour',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 60,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100]!,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Expanded(
                                      child: Text(
                                    "Color:",
                                    style: TextStyle(fontSize: 20),
                                  )),
                                  FilledButton(
                                    onPressed: () => {pickColor(context)},
                                    style: FilledButton.styleFrom(
                                        backgroundColor: _selectedColor),
                                    child: const SizedBox(
                                      height: 40,
                                      width: 70,
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Select Which Categories Affect Budget (Blank For All)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100]!,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Expanded(
                                  child: Row(
                                children: [
                                  Expanded(child: Consumer<SaveData>(
                                      builder: (context, saveData, _) {
                                    return DropDownMultiSelect(
                                      selectedValuesStyle: const TextStyle(
                                          color:
                                              Color.fromARGB(0, 255, 255, 255)),
                                      separator: ', ',
                                      onChanged: (List<String> x) {
                                        setState(() {
                                          selectedCategories = x;
                                        });
                                      },
                                      options: saveData.categories,
                                      selectedValues: selectedCategories,
                                      whenEmpty: '',
                                    );
                                  })),
                                  IconButton(
                                      onPressed: modifyCategories,
                                      icon: const Icon(Icons.more_vert))
                                ],
                              ))),
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
                                  colors: [
                                    Color.fromARGB(255, 255, 131, 90),
                                    Color.fromARGB(255, 128, 147, 241)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Container(
                                constraints:
                                    const BoxConstraints(minHeight: 60),
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
              ],
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
