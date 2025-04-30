import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../home_screen/providers/space_provider.dart';
import '../models/device_usage_model.dart';
import '../providers/room_selection_provider.dart';

class RoomUsageStats extends StatelessWidget {
  const RoomUsageStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RoomSelectionProvider, SpaceProvider>(
      builder: (context, roomProvider, spaceProvider, _) {
        final selectedSpace = spaceProvider.spaces.firstWhere(
          (space) => space.name == roomProvider.selectedRoom,
          orElse: () => spaceProvider.spaces.first,
        );
        final stats = RoomStats.getStatsForSpace(selectedSpace);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with room name and dropdown
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
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'Weekly Usage',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Device usage bars
              SizedBox(
                height: 280,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: stats.devices.map((device) {
                      // Find max usage to scale bars properly
                      final double maxUsage = stats.devices
                          .map((d) => d.usage)
                          .reduce((a, b) => a > b ? a : b);
                      // Scale height based on max usage
                      final double heightPercentage = device.usage / maxUsage;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          width: 70,
                          child: Column(
                            children: [
                              // Fixed height for top spacing and kWh text
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
                              // Flexible space for the bar
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
                                          AppColors.secondary.withOpacity(0.1),
                                          AppColors.secondary.withOpacity(0.3),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              // Fixed height for device name
                              SizedBox(
                                height: 40,
                                child: Center(
                                  child: Text(
                                    _getShortDeviceName(device.deviceName),
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
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              const SizedBox(height: 16),

              // Usage summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Electricity Consumed Section
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt,
                              color: Colors.orange,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      const Icon(
                                        Icons.arrow_upward,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Vertical Divider
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
                      // Estimated Cost Section
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.attach_money,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Estimated Cost',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '\$${stats.estimatedCost.toStringAsFixed(2)}',
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
      },
    );
  }

  // Helper method to shorten device names
  String _getShortDeviceName(String name) {
    // Remove 'Smart' prefix if present
    name = name.replaceAll('Smart ', '');
    
    // If name has multiple words and is too long, use first word
    if (name.length > 8 && name.contains(' ')) {
      return name.split(' ')[0];
    }
    
    return name;
  }
}
