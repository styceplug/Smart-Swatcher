import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.points,
    required this.dates,
    this.selectedIndex = 7, // Jul 26 in your screenshot vibe
  });

  /// y-values
  final List<double> points;

  /// same length as points
  final List<DateTime> dates;

  /// which point shows the tooltip + highlighted dot
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFFFFFFF);
    final grid = Colors.black.withOpacity(0.25);
    final orange = const Color(0xFFFF7A18);

    final spots = List.generate(
      points.length,
          (i) => FlSpot(i.toDouble(), points[i]),
    );

    final selectedX = selectedIndex.clamp(0, points.length - 1).toDouble();

    return Container(
      height: 260,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          backgroundColor: bg,
          minY: -5,
          maxY: 10,
          minX: 0,
          maxX: (points.length - 1).toDouble(),

          // grid + borders
          gridData: FlGridData(
            show: true,
            horizontalInterval: 5,
            verticalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(color: grid, strokeWidth: 1),
            getDrawingVerticalLine: (_) => FlLine(color: Colors.transparent),
          ),
          borderData: FlBorderData(show: false),

          // axis titles
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                reservedSize: 30,
                getTitlesWidget: (v, meta) => Text(
                  v.toInt().toString(),
                  style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 7,
                reservedSize: 28,
                getTitlesWidget: (v, meta) {
                  final i = v.round().clamp(0, dates.length - 1);
                  final label = DateFormat('MMM d').format(dates[i]);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),

          // tooltip
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: false, // we render our own selection by index
            touchTooltipData: LineTouchTooltipData(
              tooltipBorderRadius: BorderRadius.circular(Dimensions.radius20),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              tooltipMargin: 14,
              getTooltipColor: (_) => const Color(0xFF1A1A1A),
              getTooltipItems: (touchedSpots) {
                if (touchedSpots.isEmpty) return [];
                final s = touchedSpots.first;
                final i = s.x.round().clamp(0, dates.length - 1);
                return [
                  LineTooltipItem(
                    '${points[i].toInt()}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('MMM d').format(dates[i]),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ];
              },
            ),
            touchCallback: (event, response) {},
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((_) {
                return TouchedSpotIndicatorData(
                  FlLine(color: Colors.white.withOpacity(0.35), strokeWidth: 1),
                  FlDotData(show: false),
                );
              }).toList();
            },
          ),

          // draw the line
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: orange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) => spot.x == selectedX,
                getDotPainter: (spot, percent, barData, index) {
                  // orange dot with a subtle white glow ring like your screenshot
                  return FlDotCirclePainter(
                    radius: 6.5,
                    color: orange,
                    strokeWidth: 6,
                    strokeColor: Colors.white.withOpacity(0.12),
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],

          // force tooltip + indicator at selectedIndex
          showingTooltipIndicators: [
            ShowingTooltipIndicators([
              LineBarSpot(
                LineChartBarData(spots: spots),
                0,
                spots[selectedIndex.clamp(0, spots.length - 1)],
              )
            ])
          ],
        ),
      ),
    );
  }
}