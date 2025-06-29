import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../home_screen/providers/space_provider.dart';
import '../providers/room_selection_provider.dart';
import '../providers/energy_stats_provider.dart';
import '../../../core/services/bill_calculator_service.dart';
import '../../../core/services/energy_service.dart';

class RoomUsageStats extends StatelessWidget {
  const RoomUsageStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyService>(
      builder: (context, energyService, _) {
        return Consumer3<
          RoomSelectionProvider,
          SpaceProvider,
          EnergyStatsProvider
        >(
          builder: (context, roomProvider, spaceProvider, energyProvider, _) {
            if (spaceProvider.spaces.isEmpty) {
              return const Center(child: Text('No spaces available'));
            }

            if (energyProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            try {
              final selectedSpace = spaceProvider.spaces.firstWhere(
                (space) => space.name == roomProvider.selectedRoom,
                orElse: () => spaceProvider.spaces.first,
              );

              final stats = energyProvider.getRoomStats(selectedSpace);
              final isProtected = energyService.isProtected;
              final billDetails = BillCalculator.calculateBill(
                isUnprotected: !isProtected,
                period: 'current', // Defaulting to 'current' period
                units: stats.totalUsage.toInt(),
              );
              final estimatedCost = billDetails['totalBill'];

              if (stats.devices.isEmpty) {
                return const Center(child: Text('No energy data available'));
              }

              final double maxUsage = stats.devices
                  .map((d) => d.usage)
                  .reduce((a, b) => a > b ? a : b);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                selectedSpace.category.iconPath,
                                width: 32,
                                height: 32,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  stats.roomName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Device Usage Bars
                    SizedBox(
                      height: 280,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              stats.devices.map((device) {
                                final double heightPercentage =
                                    maxUsage > 0 ? device.usage / maxUsage : 0;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: SizedBox(
                                    width: 70,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          child: Text(
                                            '${device.usage.toStringAsFixed(1)} kWh',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: 60,
                                              height: 180 * heightPercentage,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    AppColors.secondary
                                                        .withAlpha(26),
                                                    AppColors.secondary
                                                        .withAlpha(77),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 40,
                                          child: Center(
                                            child: Text(
                                              _getShortDeviceName(
                                                device.deviceName,
                                              ),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),

                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),

                    // Summary
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Electricity Consumed
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.bolt,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Electricity Consumed',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${stats.totalUsage.toStringAsFixed(1)} kWh',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            //const Icon(Icons.arrow_upward, color: Colors.red, size: 16),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Divider
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: Colors.grey.shade200,
                              ),
                            ),
                            // Estimated Cost
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text(
                                      'Rs',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Estimated Cost',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          'Rs ${estimatedCost.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } catch (e, stackTrace) {
              print('Error in RoomUsageStats: $e');
              print('Stack trace: $stackTrace');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading energy data: ${e.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  String _getShortDeviceName(String name) {
    name = name.replaceAll('Smart ', '');
    if (name.length > 8 && name.contains(' ')) {
      return name.split(' ')[0];
    }
    return name;
  }
}
