import 'package:flutter/material.dart';

class ExpandedDropdownMenu extends StatelessWidget {
  final String initialSelection;
  final TextEditingController controller;
  final Function(String?) onSelected;
  final List<DropdownMenuEntry<String>> dropdownMenuEntries;

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
