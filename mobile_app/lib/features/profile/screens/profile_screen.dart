import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_model.dart';

import '../../../core/theme/theme_manager.dart'; // Add import

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceCharcoal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _launchUrl(String urlString, BuildContext context) async {
    final url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) _showToast(context, 'Could not launch $urlString');
      }
    } catch (e) {
      if (context.mounted) _showToast(context, 'Error launching URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = mockCurrentUser;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use Theme color
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.accentBlue,
                                AppColors.accentPurple,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentPurple.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.initials,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: TextStyle( // Dynamic text color
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color, 
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: AppColors.accentBlue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Verified Student',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.accentBlue,
                                        fontWeight: FontWeight.w600,
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

                    const SizedBox(height: 32),

                    // Stats Row
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface, // Dynamic surface
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          _StatItem(
                            value: '12',
                            label: 'Events',
                            icon: Icons.event_rounded,
                          ),
                          _StatDivider(),
                          _StatItem(
                            value: '8',
                            label: 'Attended',
                            icon: Icons.check_circle_rounded,
                          ),
                          _StatDivider(),
                          _StatItem(
                            value: '₹450',
                            label: 'Saved',
                            icon: Icons.savings_rounded,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Info Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'Student Details'),
                  const SizedBox(height: 16),
                  _InfoCard(
                    items: [
                      _InfoRow(
                        icon: Icons.badge_rounded,
                        label: 'College ID',
                        value: user.collegeId ?? 'Not set',
                      ),
                      _InfoRow(
                        icon: Icons.school_rounded,
                        label: 'Department',
                        value: user.department ?? 'Not set',
                      ),
                      _InfoRow(
                        icon: Icons.phone_rounded,
                        label: 'Phone',
                        value: user.phoneNumber ?? 'Not set',
                      ),
                      _InfoRow(
                        icon: Icons.nfc_rounded,
                        label: 'NFC Card',
                        value: user.nfcTagId != null ? 'Linked ✓' : 'Not linked',
                        valueColor: user.nfcTagId != null 
                            ? Colors.green 
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  const SizedBox(height: 32),

                  _SectionTitle(title: 'Settings'),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    items: [
                      _SettingRow(
                        icon: Icons.notifications_rounded,
                        label: 'Push Notifications',
                        trailing: Switch(
                          value: true,
                          onChanged: (v) => _showToast(context, 'Notifications updated'),
                          activeColor: AppColors.accentBlue,
                        ),
                      ),
                      _SettingRow(
                        icon: Icons.dark_mode_rounded,
                        label: 'Dark Mode',
                        trailing: ValueListenableBuilder<ThemeMode>(
                          valueListenable: ThemeManager().themeModeNotifier,
                          builder: (context, mode, _) {
                            return Switch(
                              value: mode == ThemeMode.dark,
                              onChanged: (v) {
                                ThemeManager().toggleTheme(v);
                                _showToast(context, v ? 'Dark Mode Enabled' : 'Light Mode Enabled');
                              },
                              activeColor: AppColors.accentBlue,
                            );
                          },
                        ),
                      ),
                      _SettingRow(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        trailing: Text(
                          'English',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        onTap: () => _showToast(context, 'Language selection coming soon'),
                      ),
                      _SettingRow(
                         icon: Icons.dashboard_rounded,
                         label: 'App Dashboard',
                         onTap: () {
                           HapticFeedback.mediumImpact();
                            // CAUTION: Replace 192.168.1.10 with your actual computer IP if different
                           _launchUrl('http://192.168.1.10:3000', context); 
                         }, 
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  _SectionTitle(title: 'Support'),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    items: [
                      _SettingRow(
                        icon: Icons.help_outline_rounded,
                        label: 'Help Center',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showToast(context, 'Opening Help Center...');
                        },
                      ),
                      _SettingRow(
                        icon: Icons.bug_report_rounded,
                        label: 'Report a Bug',
                         onTap: () {
                          HapticFeedback.lightImpact();
                          _showToast(context, 'Redirecting to Bug Reporter...');
                        },
                      ),
                      _SettingRow(
                        icon: Icons.info_outline_rounded,
                        label: 'About RegisterYu',
                         onTap: () {
                          HapticFeedback.lightImpact();
                          _showToast(context, 'Showing About Info...');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showToast(context, 'Logged out successfully');
                      // Navigator.of(context).pushReplacementNamed('/login'); // Uncomment when routing is set
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.2),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 16),
                  
                  // Contributors Section - Tweaked to be "Necessary and not disturbing"
                  Center(
                     child: Padding(
                       padding: const EdgeInsets.only(bottom: 8.0),
                       child: Column(
                         children: [
                           Text(
                             'Contributors',
                             style: TextStyle(
                               color: AppColors.textSecondary,
                               fontSize: 12,
                               fontWeight: FontWeight.bold,
                               letterSpacing: 1,
                             ),
                           ),
                           const SizedBox(height: 8),
                           GestureDetector(
                             onTap: () => _launchUrl('https://github.com/adithya-sambhram', context), // Placeholder GitHub
                             child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                               decoration: BoxDecoration(
                                 color: Colors.white.withOpacity(0.05),
                                 borderRadius: BorderRadius.circular(20),
                               ),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   const CircleAvatar(
                                     radius: 10,
                                     backgroundColor: AppColors.accentBlue,
                                     child: Text('A', style: TextStyle(fontSize: 10, color: Colors.white)),
                                   ),
                                   const SizedBox(width: 8),
                                   const Text(
                                     'Adithya',
                                     style: TextStyle(
                                       color: Colors.white,
                                       fontSize: 12,
                                     ),
                                   ),
                                   const SizedBox(width: 4),
                                    Icon(
                                     Icons.open_in_new_rounded,
                                     color: AppColors.textSecondary,
                                     size: 10,
                                   ),
                                 ],
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                  ),

                  const SizedBox(height: 16),

                  // Made with Love
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Made with ',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const Icon(Icons.favorite_rounded, color: Colors.red, size: 14),
                      Text(
                        ' at Sambhram',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Version
                  Center(
                    child: Text(
                      'RegisterYu v1.0.1',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentBlue, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      color: Colors.white.withOpacity(0.1),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCharcoal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Divider(
                  color: Colors.white.withOpacity(0.05),
                  height: 1,
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accentBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingRow> items;

  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCharcoal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Divider(
                  color: Colors.white.withOpacity(0.05),
                  height: 1,
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
