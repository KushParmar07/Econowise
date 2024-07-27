import 'package:econowise/save_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_bar.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => SaveData(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 58, 183, 89)),
        useMaterial3: true,
      ),
      home: const MenuSelecter(
        budgets: [],
        transactions: [],
        index: 0,
      ),
    );
  }
}
