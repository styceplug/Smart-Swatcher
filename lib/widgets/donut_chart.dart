import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

class DonutChart extends StatelessWidget {
  const DonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimensions.width100*1.5,
      height: Dimensions.height100*1.5,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          startDegreeOffset: -90,
          sections: [
            PieChartSectionData(
              value: 60,
              color: const Color(0xFF4D92FF), // blue
              radius: 60,
              showTitle: false,
            ),
            PieChartSectionData(
              value: 33,
              color: const Color(0xFFFF914D), // orange
              radius: 60,
              showTitle: false,
            ),
            PieChartSectionData(
              value: 7,
              color: const Color(0xFFFF3DA1), // pink
              radius: 60,
              showTitle: false,
            ),
          ],
        ),
      ),
    );
  }
}