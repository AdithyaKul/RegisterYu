import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:admin_app/features/dashboard/home_screen.dart';
import 'package:admin_app/features/scanner/scanner_screen.dart';
import 'package:admin_app/features/guests/guests_screen.dart';
import 'package:admin_app/features/events/events_screen.dart';
import 'package:admin_app/core/theme/app_colors.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),    // 0: Dashboard
    const GuestsScreen(),  // 1: Guests
    const SizedBox(),      // 2: Scanner (opens modal)
    const EventsScreen(),  // 3: Events
    const Center(child: Text("Settings", style: TextStyle(color: Colors.white))), // 4: Settings
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // Open Scanner Full Screen Modal
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ScannerScreen(),
          fullscreenDialog: true,
        ),
      );
      return; 
    }
    setState(() {
      _currentIndex = index;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: "Home",
                  isActive: _currentIndex == 0,
                  onTap: () => _onTabTapped(0),
                ),
                _NavItem(
                  icon: Icons.people_outline_rounded,
                  label: "Guests",
                  isActive: _currentIndex == 1,
                  onTap: () => _onTabTapped(1),
                ),
                // Floating Scan Button in Middle
                _ScanButton(
                  onTap: () => _onTabTapped(2),
                  isActive: _currentIndex == 2,
                ),
                _NavItem(
                  icon: Icons.calendar_today_rounded,
                  label: "Events",
                  isActive: _currentIndex == 3,
                  onTap: () => _onTabTapped(3),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: "Settings",
                  isActive: _currentIndex == 4,
                  onTap: () => _onTabTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.textTertiary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;

  const _ScanButton({required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? AppColors.success : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppColors.success : AppColors.primary).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
