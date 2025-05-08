import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../widgets/profile_section_card.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isFaqExpanded = false;
  bool isContactExpanded = false;

  final List<Map<String, String>> faqs = [
    {
      'question': 'How to add a new device?',
      'answer': 'Go to My Spaces and tap on the + button to add a new device.',
    },
    {
      'question': 'How to set energy limits?',
      'answer':
          'Visit the Home screen and tap on Monthly Limit card to set your desired energy consumption limit.',
    },
    {
      'question': 'How to create routines?',
      'answer':
          'Navigate to Smart AI Routine tab and tap Create New Routine to set up automated device controls.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final profile = ProfileModel.dummyProfile;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // User Information Section
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profile.profilePicture),
                      backgroundColor: AppColors.primary.withAlpha(26),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          label: Text(
                            'ID: ${profile.householdId}',
                            style: const TextStyle(color: AppColors.textWhite),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            profile.accountType,
                            style: const TextStyle(color: AppColors.textWhite),
                          ),
                          backgroundColor: AppColors.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Support & Help Section
            ProfileSectionCard(
              title: 'Support & Help',
              child: Column(
                children: [
                  // FAQ Section
                  ExpansionTile(
                    leading: Icon(
                      Icons.question_answer_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'FAQ',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Get answers to common questions',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    children:
                        faqs
                            .map(
                              (faq) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      faq['question']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      faq['answer']!,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),

                  // Contact Support Section
                  ExpansionTile(
                    leading: Icon(
                      Icons.support_agent_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'Contact Support',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Available 24/7 for assistance',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.message_rounded,
                          color: AppColors.success,
                        ),
                        title: const Text('+92 315 0261059'),
                        subtitle: const Text('WhatsApp Support'),
                        onTap: () {
                          // TODO: Open WhatsApp
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                        ),
                        title: const Text('msufiyan.dev@gmail.com'),
                        subtitle: const Text('Email Support'),
                        onTap: () {
                          // TODO: Open email client
                        },
                      ),
                    ],
                  ),

                  // Terms and Privacy
                  ListTile(
                    leading: Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'Terms of Service & Privacy Policy',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Read our policies and terms',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                    ),
                    onTap: () {
                      // TODO: Navigate to Terms
                    },
                  ),
                ],
              ),
            ),

            // Account Management Section
            ProfileSectionCard(
              title: 'Account Management',
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.lock_outline, color: AppColors.primary),
                    title: Text(
                      'Change Password',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Update your account password',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                    ),
                    onTap: () {
                      // TODO: Implement password change
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout_rounded, color: AppColors.error),
                    title: Text(
                      'Logout',
                      style: TextStyle(color: AppColors.error),
                    ),
                    subtitle: Text(
                      'Sign out from your account',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right, color: AppColors.error),
                    onTap: () {
                      // TODO: Implement logout
                    },
                  ),
                ],
              ),
            ),

            // App Version and Credits
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                children: [
                  const TextSpan(text: 'App Version '),
                  TextSpan(
                    text: '1.0.0',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: 'Developed by '),
                      TextSpan(
                        text: 'DUET Students',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' with '),
                    ],
                  ),
                ),
                const Icon(Icons.favorite, color: AppColors.error, size: 16),
                const SizedBox(width: 2),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
