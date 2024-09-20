import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Budget {
  String goal;
  double budgetAmount;
  DateTime? startDate;
  DateTime? endDate;
  IconData icon;
  double totalUsed = 0;
  Color color = Colors.blue;
  double warningAmount = 0;
  Budget(this.goal, this.budgetAmount, this.startDate, this.endDate, this.icon,
      this.color, this.warningAmount);

  Map<String, dynamic> toJson() => {
        'goal': goal,
        'budgetAmount': budgetAmount,
        'startDate': startDate,
        'endDate': endDate,
        'icon': icon.codePoint, // Store the icon code point
        'totalUsed': totalUsed,
        'color': color.value, // Store the color's integer value
        'warningAmount': warningAmount,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        json['goal'],
        json['budgetAmount'],
        (json['startDate'] as Timestamp).toDate(),
        (json['endDate'] as Timestamp).toDate(),
        IconData(json['icon'], fontFamily: 'MaterialIcons'),
        Color(json['color']),
        json['warningAmount'],
      )..totalUsed = json['totalUsed'];
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Budget &&
        goal == other.goal &&
        budgetAmount == other.budgetAmount &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        icon == other.icon &&
        color == other.color &&
        warningAmount == other.warningAmount;
  }

  @override
  int get hashCode => Object.hash(
        goal,
        budgetAmount,
        startDate,
        endDate,
        icon,
        color,
        warningAmount,
      );
}
