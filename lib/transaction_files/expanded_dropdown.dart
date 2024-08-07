import 'package:flutter/material.dart';
import 'package:econowise/budget_files/budget.dart';

class ExpandedDropdownMenu extends StatelessWidget {
  final Budget initialSelection;
  final TextEditingController controller;
  final Function(Budget?) onSelected;
  final List<DropdownMenuEntry<Budget>> dropdownMenuEntries;

  const ExpandedDropdownMenu({
    required this.initialSelection,
    required this.controller,
    required this.onSelected,
    required this.dropdownMenuEntries,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu(
          initialSelection: initialSelection,
          controller: controller,
          onSelected: onSelected,
          dropdownMenuEntries: dropdownMenuEntries,
          width: constraints.maxWidth, // Force full width
        );
      },
    );
  }
}
