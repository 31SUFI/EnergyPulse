import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../model/space_model.dart';
import 'add_space_dialog.dart';

class MySpaces extends StatefulWidget {
  const MySpaces({super.key});

  @override
  State<MySpaces> createState() => _MySpacesState();
}

class _MySpacesState extends State<MySpaces> {
  final List<Space> _spaces = [
    Space(
      name: 'Master Bedroom',
      category: SpaceCategory.bedroom,
      energyConsumption: 2.5,
    ),
    Space(
      name: 'Kitchen',
      category: SpaceCategory.kitchen,
      energyConsumption: 4.2,
    ),
  ];

  void _addNewSpace(Space space) {
    setState(() {
      _spaces.add(space);
    });
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
                    builder: (context) => const AddSpaceDialog(),
                  );
                  if (newSpace != null) {
                    _addNewSpace(newSpace);
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
          if (_spaces.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No spaces added yet',
                    style: TextStyle(
                      fontFamily: 'AnekLatin',
                      fontSize: 16,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.0,
              children:
                  _spaces
                      .map(
                        (space) => _buildSpaceCard(
                          image: space.category.iconPath,
                          name: space.name,
                          usage: space.energyConsumption.toStringAsFixed(1),
                          cost: (space.energyConsumption * 0.25)
                              .toStringAsFixed(2),
                          showTrend: false,
                        ),
                      )
                      .toList(),
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
            color: Colors.black.withOpacity(0.05),
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
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$cost',
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
