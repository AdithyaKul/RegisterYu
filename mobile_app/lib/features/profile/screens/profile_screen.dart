import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_manager.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/theme_manager.dart';
import '../../auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _stats = {'total': 0, 'attended': 0, 'upcoming': 0, 'saved': 0.0};
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    if (!AuthManager.instance.isLoggedIn) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final stats = await SupabaseService.instance.getUserStats(AuthManager.instance.userId);
      // Refresh auth profile to get latest details if edited
      // AuthManager.instance.refreshProfile() logic goes here if implemented
      // For now we assume local update or fetch new profile
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCharcoal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out of your account?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    setState(() => _isLoggingOut = true);
    
    try {
      await AuthManager.instance.signOut();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoggingOut = false);
      if (mounted) _showToast(context, 'Failed to sign out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthManager.instance,
      builder: (context, _) {
        final auth = AuthManager.instance;
        // User currentUser is updated via AuthManager notification usually
        // But we access UserModel directly if available
        // We'll rely on the Supabase profile fetch for displayed detailed data if AuthManager doesn't have it all yet
        // However, EditProfile pushed updates might need a reload.
        
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: _loadUserStats,
            color: AppColors.accentBlue,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                                    auth.userInitials,
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
                                      auth.userName,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      auth.userEmail,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Edit Profile Button
                                    GestureDetector(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                                        );
                                        if (result == true) {
                                          _loadUserStats(); // Reload to refresh fields (if we were fetching full profile here)
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.accentBlue),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            color: AppColors.accentBlue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).dividerColor.withOpacity(0.1),
                              ),
                            ),
                            child: _isLoading
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(color: AppColors.accentBlue),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      _StatItem(
                                        value: '${_stats['total']}',
                                        label: 'Events',
                                        icon: Icons.event_rounded,
                                      ),
                                      _StatDivider(),
                                      _StatItem(
                                        value: '${_stats['attended']}',
                                        label: 'Attended',
                                        icon: Icons.check_circle_rounded,
                                      ),
                                      _StatDivider(),
                                      _StatItem(
                                        value: '₹${(_stats['saved'] as num).toInt()}',
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
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: SupabaseService.instance.getProfile(auth.userId), // Fetch fresh profile
                      builder: (context, snapshot) {
                        final profile = snapshot.data;
                        final String usn = profile?['usn'] ?? 'Not Set';
                        final String sem = profile?['semester'] ?? '-';
                        final String sec = profile?['section'] ?? '-';
                        final String dept = profile?['department'] ?? 'Not Set';
                        final String phone = profile?['phone_number'] ?? 'Not Set';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTitle(title: 'Student Details'),
                            const SizedBox(height: 16),
                            _InfoCard(
                              items: [
                                _InfoRow(
                                  icon: Icons.badge_rounded,
                                  label: 'USN',
                                  value: usn,
                                ),
                                _InfoRow(
                                  icon: Icons.school_rounded,
                                  label: 'Department',
                                  value: dept,
                                ),
                                _InfoRow(
                                  icon: Icons.calendar_view_day_rounded,
                                  label: 'Semester / Section',
                                  value: '$sem / $sec',
                                ),
                                _InfoRow(
                                  icon: Icons.phone_rounded,
                                  label: 'Phone',
                                  value: phone,
                                ),
                              ],
                            ),

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
                                  icon: Icons.dashboard_rounded,
                                  label: 'Admin Dashboard',
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    _launchUrl('https://registeryu-dashboard.vercel.app', context);
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
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: AppColors.surfaceCharcoal,
                                        title: const Text('Help Center', style: TextStyle(color: Colors.white)),
                                        content: const Text('For support, please contact the event organizers or email: support@sambhram.edu', style: TextStyle(color: Colors.white70)),
                                        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                                      ),
                                    );
                                  },
                                ),
                                _SettingRow(
                                  icon: Icons.bug_report_rounded,
                                  label: 'Report a Bug',
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _launchUrl('mailto:bugs@registeryu.com?subject=Bug Report', context);
                                  },
                                ),
                                _SettingRow(
                                  icon: Icons.info_outline_rounded,
                                  label: 'About RegisterYu',
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _showAboutDialog();
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Logout Button
                            GestureDetector(
                              onTap: _isLoggingOut ? null : _handleLogout,
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isLoggingOut)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.red,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    else ...[
                                      const Icon(
                                        Icons.logout_rounded,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Sign Out',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Contributors
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
                                      onTap: () => _launchUrl('https://github.com/adithya-sambhram', context),
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
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                                const Icon(Icons.favorite_rounded, color: Colors.red, size: 14),
                                Text(
                                  ' at Sambhram',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                        );
                      }
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCharcoal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentBlue, AppColors.accentPurple],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            const Text('RegisterYu', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.1',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your gateway to college events. Register, pay, and attend events seamlessly with NFC-enabled check-ins.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 Sambhram College',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.accentBlue)),
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
      onTap: onTap,
    );
  }
}
