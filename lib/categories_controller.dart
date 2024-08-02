import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'save_data.dart';

Future<void> modifyCategories(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Categories'),
        content: Consumer<SaveData>(
          // Use Consumer from Provider
          builder: (context, saveData, child) {
            final filteredCategories = saveData.categories
                .where((category) => category != "")
                .toList();

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredCategories.length + 1,
                itemBuilder: (BuildContext context, index) {
                  if (index == 0) {
                    return ElevatedButton(
                      onPressed: () => createCategory(context),
                      child: const Text("New Category"),
                    );
                  } else {
                    var category = filteredCategories[index - 1];
                    return Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(category),
                          IconButton(
                            onPressed: () {
                              saveData.deleteCategory(
                                  category); // Directly update SaveData
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
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

Future<void> createCategory(context) async {
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
              context.read<SaveData>().addCategory(categoryTitle.text);

              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
