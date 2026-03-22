import 'package:flutter/material.dart';

enum BeverageType {
  water,
  coffee,
  tea,
  juice,
  soda,
}

extension BeverageTypeExtension on BeverageType {
  double get hydrationMultiplier {
    switch (this) {
      case BeverageType.water:
        return 1.0;
      case BeverageType.coffee:
        return 1.0;
      case BeverageType.tea:
        return 1.0;
      case BeverageType.juice:
        return 1.0;
      case BeverageType.soda:
        return 1.0;
    }
  }

  String get displayName {
    switch (this) {
      case BeverageType.water:
        return 'Water';
      case BeverageType.coffee:
        return 'Coffee';
      case BeverageType.tea:
        return 'Tea';
      case BeverageType.juice:
        return 'Juice';
      case BeverageType.soda:
        return 'Soda';
    }
  }

  IconData get icon {
    switch (this) {
      case BeverageType.water:
        return Icons.water_drop;
      case BeverageType.coffee:
        return Icons.coffee;
      case BeverageType.tea:
        return Icons.emoji_food_beverage;
      case BeverageType.juice:
        return Icons.local_drink;
      case BeverageType.soda:
        return Icons.fastfood;
    }
  }

  Color get color {
    switch (this) {
      case BeverageType.water:
        return Colors.blue;
      case BeverageType.coffee:
        return Colors.brown;
      case BeverageType.tea:
        return Colors.green;
      case BeverageType.juice:
        return Colors.orange;
      case BeverageType.soda:
        return Colors.redAccent;
    }
  }

  /// Sensible default amount in ml for each beverage type.
  int get defaultAmountMl {
    switch (this) {
      case BeverageType.water:
        return 250;
      case BeverageType.coffee:
        return 120;
      case BeverageType.tea:
        return 150;
      case BeverageType.juice:
        return 200;
      case BeverageType.soda:
        return 250;
    }
  }

  /// Quick-add presets (small, medium, large) in ml.
  List<int> get quickAddPresetsMl {
    switch (this) {
      case BeverageType.water:
        return [100, 250, 500];
      case BeverageType.coffee:
        return [60, 120, 200];
      case BeverageType.tea:
        return [100, 150, 250];
      case BeverageType.juice:
        return [100, 200, 350];
      case BeverageType.soda:
        return [150, 250, 350];
    }
  }

  /// Labels for quick-add presets.
  List<String> get quickAddLabels {
    switch (this) {
      case BeverageType.water:
        return ['SMALL CUP', 'GLASS', 'BOTTLE'];
      case BeverageType.coffee:
        return ['ESPRESSO', 'CUP', 'LARGE'];
      case BeverageType.tea:
        return ['SMALL', 'CUP', 'MUG'];
      case BeverageType.juice:
        return ['SMALL', 'GLASS', 'LARGE'];
      case BeverageType.soda:
        return ['SMALL', 'CAN', 'LARGE'];
    }
  }

  /// Amount (ml) above which a mild warning is shown.
  int get warningThresholdMl {
    switch (this) {
      case BeverageType.water:
        return 1000; // Water is fine in large amounts
      case BeverageType.coffee:
        return 250;
      case BeverageType.tea:
        return 300;
      case BeverageType.juice:
        return 400;
      case BeverageType.soda:
        return 330;
    }
  }

  /// Amount (ml) above which a confirmation dialog is required.
  int get extremeThresholdMl {
    switch (this) {
      case BeverageType.water:
        return 2000;
      case BeverageType.coffee:
        return 500;
      case BeverageType.tea:
        return 600;
      case BeverageType.juice:
        return 800;
      case BeverageType.soda:
        return 700;
    }
  }
}

/// Returns a warning string if the amount is unusually high for the beverage, or null.
String? getHighAmountWarning(BeverageType type, int amountMl) {
  if (amountMl <= type.warningThresholdMl) return null;
  if (amountMl > type.extremeThresholdMl) {
    return '⚠️ ${amountMl}ml of ${type.displayName} is extremely high. '
        'This much ${type.displayName.toLowerCase()} at once is not recommended.';
  }
  // Mild warning
  switch (type) {
    case BeverageType.coffee:
      return '☕ ${amountMl}ml of coffee is quite a lot — consider a smaller serving for better hydration.';
    case BeverageType.tea:
      return '🍵 ${amountMl}ml of tea is more than a typical cup — just a heads-up!';
    case BeverageType.soda:
      return '🥤 ${amountMl}ml of soda is a large serving — keep sugar intake in mind.';
    case BeverageType.juice:
      return '🧃 ${amountMl}ml of juice is generous — watch the sugar content.';
    case BeverageType.water:
      return null; // Water is generally safe
  }
}

