import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/monthly_limit_provider.dart';

class MonthlyLimitCard extends StatelessWidget {
  const MonthlyLimitCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with limit info and edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Limit',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Consumer<MonthlyLimitProvider>(
                      builder: (context, provider, child) {
                        return Text(
                          '${provider.currentUsage.toStringAsFixed(2)} units / ${provider.limit.toStringAsFixed(0)} units',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.textSecondary),
                  onPressed: () => _showEditLimitDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Consumer<MonthlyLimitProvider>(
                builder: (context, provider, child) {
                  final percentage = provider.usagePercentage;
                  return LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage > 0.9
                          ? AppColors.error
                          : percentage > 0.7
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                    minHeight: 8,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Usage graph
            Consumer<MonthlyLimitProvider>(
              builder: (context, monthlyLimitProvider, _) {
                // Find min and max values for scaling
                final limit = monthlyLimitProvider.limit;
final maxY = (limit > 0 && limit.isFinite) ? limit * 1.1 : 100.0;
final minY = 0.0;
final maxX = 30.0; // Days in month

                return SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      minX: 1,
                      maxX: maxX,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: (maxY / 5).isFinite && (maxY / 5) > 0 ? maxY / 5 : 20.0, // Show 5 horizontal lines
verticalInterval: 5, // Show vertical line every 5 days
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[300]!,
                            strokeWidth:
                                value == monthlyLimitProvider.limit ? 1.5 : 0.5,
                            dashArray:
                                value == monthlyLimitProvider.limit
                                    ? [5, 5]
                                    : null,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey[300]!,
                            strokeWidth: 0.5,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 5, // Show label every 5 days
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() % 5 != 0 &&
                                  value != 1 &&
                                  value != 30) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8,
                                child: Text(
                                  'Day ${value.isFinite ? value.toInt() : 0}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: (maxY / 4).isFinite && (maxY / 4) > 0 ? maxY / 4 : 25.0, // Show 4 labels on Y axis
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  value.isFinite ? value.toInt().toString() : '0',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.white,
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.isFinite ? spot.y.toInt() : 0} units\nDay ${spot.x.isFinite ? spot.x.toInt() : 0}',
                                const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        // Actual usage line
                        LineChartBarData(
                          spots: List.generate(
                            monthlyLimitProvider.dailyUsage.length,
                            (index) => FlSpot(
                              (index + 1).toDouble(),
                              monthlyLimitProvider.dailyUsage[index],
                            ),
                          ),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              // Only show dot for the last point
                              return index ==
                                      monthlyLimitProvider.dailyUsage.length - 1
                                  ? FlDotCirclePainter(
                                    radius: 4,
                                    color: AppColors.primary,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  )
                                  : FlDotCirclePainter(radius: 0);
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary.withOpacity(0.2),
                                AppColors.primary.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),
                        // Limit line
                        LineChartBarData(
                          spots: [
                            FlSpot(1, monthlyLimitProvider.limit),
                            FlSpot(
                              monthlyLimitProvider.dailyUsage.length.toDouble(),
                              monthlyLimitProvider.limit,
                            ),
                          ],
                          color: AppColors.error,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          dashArray: [5, 5],
                        ),
                        // Projection line
                        LineChartBarData(
                          spots:
                              [
                                if (monthlyLimitProvider.dailyUsage.isNotEmpty)
                                  FlSpot(
                                    monthlyLimitProvider.dailyUsage.length
                                        .toDouble(),
                                    monthlyLimitProvider.dailyUsage.last,
                                  ),
                                ...monthlyLimitProvider
                                    .getProjectedUsage()
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => FlSpot(
                                        monthlyLimitProvider.dailyUsage.length +
                                            entry.key +
                                            1,
                                        entry.value,
                                      ),
                                    ),
                              ].toList(),
                          color: AppColors.textSecondary,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          dashArray: [3, 3],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Legend
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(context, 'Actual Usage', AppColors.primary),
                  const SizedBox(width: 16),
                  _buildLegendItem(context, 'Limit', AppColors.error),
                  const SizedBox(width: 16),
                  _buildLegendItem(
                    context,
                    'Projected',
                    AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditLimitDialog(BuildContext context) async {
    final provider = Provider.of<MonthlyLimitProvider>(context, listen: false);
    final controller = TextEditingController(
      text: provider.limit.toStringAsFixed(2),
    );

    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Set Monthly Limit'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Limit (units)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.speed, color: AppColors.primary),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () async {
                  final newLimit = double.tryParse(controller.text) ?? 0;
                  if (newLimit > 0) {
                    await provider.setLimit(newLimit);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('SAVE'),
              ),
            ],
          ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 2,
            color: color,
            margin: const EdgeInsets.only(right: 4),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
