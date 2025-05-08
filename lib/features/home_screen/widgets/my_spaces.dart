import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../model/space_model.dart';
import '../providers/space_provider.dart';
import 'add_space_dialog.dart';

class MySpaces extends StatefulWidget {
  const MySpaces({super.key});

  @override
  State<MySpaces> createState() => _MySpacesState();
}

class _MySpacesState extends State<MySpaces> {
  void _addNewSpace(BuildContext context, Space space) {
    context.read<SpaceProvider>().addSpace(space);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Spaces',
                style: TextStyle(
                  fontFamily: 'AnekLatin',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final newSpace = await showDialog<Space>(
                    context: context,
                    builder: (dialogContext) => const AddSpaceDialog(),
                  );
                  if (!mounted) return;
                  if (newSpace != null) {
                    _addNewSpace(context, newSpace);
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.add, size: 20, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Add New Space',
                      style: TextStyle(
                        fontFamily: 'AnekLatin',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (context.watch<SpaceProvider>().spaces.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 48,
                    color: AppColors.textSecondary.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No spaces added yet',
                    style: TextStyle(
                      fontFamily: 'AnekLatin',
                      fontSize: 16,
                      color: AppColors.textSecondary.withAlpha(128),
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: context.watch<SpaceProvider>().spaces.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.0,
              ),
              itemBuilder: (context, index) {
                final space = context.watch<SpaceProvider>().spaces[index];
                return _buildSpaceCard(
                  image: space.category.iconPath,
                  name: space.name,
                  usage: space.energyConsumption.toStringAsFixed(1),
                  cost: (space.energyConsumption * 0.25).toStringAsFixed(2),
                  showTrend: false,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSpaceCard({
    required String image,
    required String name,
    required String usage,
    required String cost,
    bool showTrend = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(image, width: 20, height: 20),
              const SizedBox(width: 6),
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'AnekLatin',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Usage with trend
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, size: 16, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    '$usage kWh',
                    style: const TextStyle(
                      fontFamily: 'AnekLatin',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (showTrend)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Icon(
                        Icons.arrow_drop_up,
                        size: 16,
                        color: Colors.red.shade400,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
              Container(height: 16, width: 1, color: const Color(0xFFEEEEEE)),
              const SizedBox(width: 4),
              // Cost
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/money.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(Colors.amber, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    cost,
                    style: const TextStyle(
                      fontFamily: 'AnekLatin',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
