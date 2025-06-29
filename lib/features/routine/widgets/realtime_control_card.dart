import 'package:energy_meter_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/firebase_realtime_provider.dart';

class RealtimeControlCard extends StatelessWidget {
  const RealtimeControlCard({super.key});

  // Map relay numbers to device info, same as in FirebaseScheduleCard
  static final Map<int, ({String name, String icon})> _relayDevices = {
    1: (name: 'Smart Light', icon: '💡'),
    2: (name: 'Smart Fan', icon: '🌀'),
    3: (name: 'Smart Heater', icon: '🔥'),
    4: (name: 'Smart AC', icon: '❄️'),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Real-time Appliances Control',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Consumer<FirebaseRealtimeProvider>(
          builder: (context, provider, child) {
            return StreamBuilder<Map<String, bool>>(
              stream: provider.getRelayStates(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No relays found.'));
                }

                final relayStates = snapshot.data!;
                return Column(
                  children:
                      relayStates.entries.map((entry) {
                        final relayId = entry.key;
                        final isRelayOn = entry.value;

                        final relayNumber =
                            int.tryParse(relayId.replaceAll('relay', '')) ?? 0;
                        final device =
                            _relayDevices[relayNumber] ??
                            (name: 'Relay $relayNumber', icon: '🔌');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Center(
                                  child: Text(
                                    device.icon,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  device.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Switch.adaptive(
                                value: isRelayOn,
                                onChanged: (value) {
                                  provider.toggleRelayState(relayId, isRelayOn);
                                },
                                activeColor: AppColors.secondary,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
