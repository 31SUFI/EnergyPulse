import 'package:energy_meter_app/features/stats_screen/view/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/energy_service.dart';

class TodayUsageCard extends StatefulWidget {
  const TodayUsageCard({super.key});

  @override
  State<TodayUsageCard> createState() => _TodayUsageCardState();
}

class _TodayUsageCardState extends State<TodayUsageCard> {
  bool _isExpanded = false;

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBill(Map<String, dynamic> billDetails) {
    final slabDescription = billDetails['slabDescription'] as String? ?? 'N/A';
    final ratePerUnit = (billDetails['ratePerUnit'] as num?)?.toDouble() ?? 0.0;
    final energyCharges =
        (billDetails['energyCharges'] as num?)?.toDouble() ?? 0.0;
    final fixedCharges =
        (billDetails['fixedCharges'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),
          _buildDetailRow('Tariff Slab', slabDescription),
          _buildDetailRow(
            'Rate per Unit',
            'Rs. ${ratePerUnit.toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            'Energy Charges',
            'Rs. ${energyCharges.toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            'Fixed Charges',
            'Rs. ${fixedCharges.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyService>(
      builder: (context, energyService, child) {
        final billDetails = energyService.billDetails;
        final totalBill = billDetails['totalBill'] ?? 0.0;

        return Container(
          margin: const EdgeInsets.all(16.0),
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
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                  child: Text(
                    'Estimated Cost & Units',
                    style: TextStyle(
                      fontFamily: 'AnekLatin',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Electricity Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Electricity',
                                style: TextStyle(
                                  fontFamily: 'AnekLatin',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    energyService.totalEnergy.toStringAsFixed(
                                      1,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'AnekLatin',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'kWh',
                                    style: TextStyle(
                                      fontFamily: 'AnekLatin',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Cost Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cost',
                                style: TextStyle(
                                  fontFamily: 'AnekLatin',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    totalBill.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontFamily: 'AnekLatin',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PKR',
                                    style: TextStyle(
                                      fontFamily: 'AnekLatin',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: Center(
                    child: Icon(
                      Icons.expand_more,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                  secondChild: _buildDetailedBill(billDetails),
                  crossFadeState:
                      _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const StatsScreen(),
                      //   ),
                      // );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'View Bill Summary',
                          style: TextStyle(
                            fontFamily: 'AnekLatin',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary,
                          ),
                        ),
                        Icon(
                          Icons.arrow_upward,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
