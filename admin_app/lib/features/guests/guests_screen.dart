import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:admin_app/core/theme/app_colors.dart';
import 'package:admin_app/core/data/admin_repository.dart';

class GuestsScreen extends StatefulWidget {
  const GuestsScreen({super.key});

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  final _repository = AdminRepository();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _guests = [];
  List<Map<String, dynamic>> _filteredGuests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    setState(() => _isLoading = true);
    try {
      final guests = await _repository.getGuests();
      if (mounted) {
        setState(() {
          _guests = guests;
          _filteredGuests = guests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterGuests(String query) {
    if (query.isEmpty) {
      setState(() => _filteredGuests = _guests);
      return;
    }
    
    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredGuests = _guests.where((guest) {
        final profile = guest['profiles'] as Map<String, dynamic>?;
        final name = (profile?['full_name'] ?? '').toString().toLowerCase();
        final email = (profile?['email'] ?? '').toString().toLowerCase();
        final ticketId = (guest['id'] ?? '').toString().toLowerCase();
        return name.contains(lowercaseQuery) || 
               email.contains(lowercaseQuery) ||
               ticketId.contains(lowercaseQuery);
      }).toList();
    });
  }

  Future<void> _checkInGuest(String ticketId) async {
    try {
      HapticFeedback.mediumImpact();
      await _repository.checkInUser(ticketId);
      _loadGuests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Checked in successfully!"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Guests",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_guests.length} registered",
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterGuests,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: "Search guests...",
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Guest List
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_filteredGuests.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_search_rounded, 
                      size: 64, 
                      color: AppColors.textTertiary
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No guests found",
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final guest = _filteredGuests[index];
                    return _GuestCard(
                      guest: guest,
                      onCheckIn: () => _checkInGuest(guest['id']),
                    );
                  },
                  childCount: _filteredGuests.length,
                ),
              ),
            ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  final Map<String, dynamic> guest;
  final VoidCallback onCheckIn;

  const _GuestCard({required this.guest, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final profile = guest['profiles'] as Map<String, dynamic>?;
    final name = profile?['full_name'] ?? 'Unknown Guest';
    final email = profile?['email'] ?? '';
    final status = guest['status'] ?? 'pending';
    final isCheckedIn = status == 'checked_in';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCheckedIn 
            ? AppColors.success.withOpacity(0.3) 
            : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isCheckedIn ? null : onCheckIn,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isCheckedIn 
                      ? AppColors.success.withOpacity(0.15)
                      : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: TextStyle(
                        color: isCheckedIn ? AppColors.success : AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCheckedIn 
                      ? AppColors.success.withOpacity(0.15)
                      : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCheckedIn 
                        ? AppColors.success.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    isCheckedIn ? "CHECKED IN" : "PENDING",
                    style: TextStyle(
                      color: isCheckedIn ? AppColors.success : AppColors.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
