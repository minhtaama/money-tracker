import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/presentation/custom_pie_chart.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 300, width: double.infinity, child: CustomPieChart());
  }
}
