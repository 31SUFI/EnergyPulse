import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/firebase_realtime_provider.dart';

class RealtimeControlCard extends StatelessWidget {
  const RealtimeControlCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-time Relay Control',
              style: Theme.of(context).textTheme.titleLarge,
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
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: relayStates.length,
                      itemBuilder: (context, index) {
                        final relayId = relayStates.keys.elementAt(index);
                        final isRelayOn = relayStates[relayId]!;
                        return SwitchListTile(
                          title: Text(relayId),
                          value: isRelayOn,
                          onChanged: (value) {
                            provider.toggleRelayState(relayId, isRelayOn);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
