import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/auth_manager.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedTicket = -1;
  List<_TicketData> _tickets = [];
  bool _isLoading = true;
  Map<String, dynamic> _stats = {'attended': 0, 'upcoming': 0, 'saved': 0.0};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    if (!AuthManager.instance.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Load registrations from Supabase
      final registrations = await SupabaseService.instance
          .getUserRegistrations(AuthManager.instance.userId);
      
      // Load user stats
      final stats = await SupabaseService.instance
          .getUserStats(AuthManager.instance.userId);

      final tickets = registrations.map((reg) {
        final event = reg['events'] as Map<String, dynamic>?;
        final eventDate = DateTime.tryParse(event?['date'] ?? '') ?? DateTime.now();
        final isUpcoming = eventDate.isAfter(DateTime.now());
        
        return _TicketData(
          id: reg['id'] as String,
          eventId: reg['event_id'] as String,
          eventName: event?['title'] ?? 'Unknown Event',
          date: _formatDate(eventDate),
          location: event?['location'] ?? 'TBA',
          ticketNumber: reg['ticket_code'] ?? 'TKT-${reg['id'].substring(0, 8)}',
          status: reg['status'] ?? 'active',
          isCheckedIn: reg['check_in_time'] != null,
          gradientColors: isUpcoming 
              ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
              : [const Color(0xFF11998e), const Color(0xFF38ef7d)],
        );
      }).toList();

      setState(() {
        _tickets = tickets;
        _stats = stats;
        _isLoading = false;
      });
      
      _controller.forward();
    } catch (e) {
      debugPrint('Error loading tickets: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day} • $hour:${date.minute.toString().padLeft(2, '0')} $amPm';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: RefreshIndicator(
        onRefresh: _loadTickets,
        color: AppColors.accentBlue,
        backgroundColor: AppColors.surfaceCharcoal,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.white, Colors.white70],
                                ).createShader(bounds),
                                child: const Text(
                                  'My Tickets',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _tickets.isNotEmpty ? Colors.green : Colors.grey,
                                      shape: BoxShape.circle,
                                      boxShadow: _tickets.isNotEmpty ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.5),
                                          blurRadius: 6,
                                        ),
                                      ] : [],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isLoading 
                                        ? 'Loading...'
                                        : '${_stats['upcoming']} upcoming events',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _HeaderButton(
                            icon: Icons.qr_code_scanner_rounded,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // Could open a QR scanner for check-in
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Quick Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Attended',
                        value: '${_stats['attended']}',
                        icon: Icons.check_circle_rounded,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Upcoming',
                        value: '${_stats['upcoming']}',
                        icon: Icons.event_rounded,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Saved',
                        value: '₹${(_stats['saved'] as num).toInt()}',
                        icon: Icons.savings_rounded,
                        color: AppColors.accentPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accentBlue, AppColors.accentPurple],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Active Tickets',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading State
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(60),
                    child: CircularProgressIndicator(color: AppColors.accentBlue),
                  ),
                ),
              ),

            // Empty State
            if (!_isLoading && _tickets.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 80,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No tickets yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Register for events to see your tickets here',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Tickets List
            if (!_isLoading && _tickets.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final delay = index * 0.15;
                          final animation = CurvedAnimation(
                            parent: _controller,
                            curve: Interval(
                              delay.clamp(0.0, 0.7),
                              (delay + 0.5).clamp(0.0, 1.0),
                              curve: Curves.easeOutCubic,
                            ),
                          );

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _TicketCard(
                            ticket: _tickets[index],
                            isExpanded: _selectedTicket == index,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                _selectedTicket = _selectedTicket == index ? -1 : index;
                              });
                            },
                          ),
                        ),
                      );
                    },
                    childCount: _tickets.length,
                  ),
                ),
              ),

            // Empty space at bottom
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceCharcoal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCharcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketData {
  final String id;
  final String eventId;
  final String eventName;
  final String date;
  final String location;
  final String ticketNumber;
  final String status;
  final bool isCheckedIn;
  final List<Color> gradientColors;

  _TicketData({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.date,
    required this.location,
    required this.ticketNumber,
    required this.status,
    required this.isCheckedIn,
    required this.gradientColors,
  });
}

class _TicketCard extends StatelessWidget {
  final _TicketData ticket;
  final bool isExpanded;
  final VoidCallback onTap;

  const _TicketCard({
    required this.ticket,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Generate QR data for scanning
    final qrData = 'RYU|${ticket.eventId}|${ticket.ticketNumber}|${AuthManager.instance.userId}';
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ticket.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ticket.gradientColors[0].withOpacity(0.4),
              blurRadius: isExpanded ? 30 : 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main Ticket Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: ticket.isCheckedIn ? Colors.green : Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ticket.isCheckedIn ? 'CHECKED IN' : 'ACTIVE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        ticket.ticketNumber.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Event Name
                  Text(
                    ticket.eventName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info Row
                  Row(
                    children: [
                      _TicketInfoChip(
                        icon: Icons.calendar_today_rounded,
                        text: ticket.date,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TicketInfoChip(
                          icon: Icons.location_on_rounded,
                          text: ticket.location,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tear Line
            Row(
              children: [
                Container(
                  width: 16,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBlack,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final dashCount = (constraints.maxWidth / 12).floor();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(dashCount, (index) {
                          return Container(
                            width: 6,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                Container(
                  width: 16,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBlack,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                  ),
                ),
              ],
            ),

            // QR Section (Expandable)
            AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tap to view ticket',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    Icon(
                      Icons.qr_code_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 24,
                    ),
                  ],
                ),
              ),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Real QR Code
                          QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 140,
                            backgroundColor: Colors.white,
                            errorStateBuilder: (ctx, err) {
                              return const SizedBox(
                                width: 140,
                                height: 140,
                                child: Icon(Icons.error, size: 40, color: Colors.red),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ticket.ticketNumber.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TicketInfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}


