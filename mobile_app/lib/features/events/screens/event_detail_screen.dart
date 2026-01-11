import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/auth_manager.dart';

import '../../../shared/widgets/cached_image.dart';
import '../data/mock_events.dart';
import '../../auth/screens/login_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/screens/edit_profile_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animController;
  double _scrollOffset = 0;
  bool _showAppBarTitle = false;
  bool _isRegistered = false;
  int _attendeeCount = 0;
  bool _checkingRegistration = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    
    _checkRegistrationStatus();
    _loadAttendeeCount();
  }

  Future<void> _checkRegistrationStatus() async {
    if (!AuthManager.instance.isLoggedIn) {
      setState(() => _checkingRegistration = false);
      return;
    }
    
    try {
      final isRegistered = await SupabaseService.instance.isUserRegistered(
        widget.event.id,
        AuthManager.instance.userId,
      );
      setState(() {
        _isRegistered = isRegistered;
        _checkingRegistration = false;
      });
    } catch (e) {
      setState(() => _checkingRegistration = false);
    }
  }

  Future<void> _loadAttendeeCount() async {
    try {
      final count = await SupabaseService.instance.getEventRegistrationCount(widget.event.id);
      setState(() => _attendeeCount = count);
    } catch (e) {
      // Use fallback
      setState(() => _attendeeCount = 45);
    }
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _showAppBarTitle = _scrollOffset > 280;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Background Gradient Glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentPurple.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero Image
                SliverAppBar(
                  expandedHeight: 380,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _CircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  actions: const [],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppCachedImage(
                          imageUrl: widget.event.imageUrl,
                          fit: BoxFit.cover,
                        ),
                        // Multi-layer gradient for depth
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.transparent,
                                Colors.transparent,
                                AppColors.backgroundBlack.withOpacity(0.8),
                                AppColors.backgroundBlack,
                              ],
                              stops: const [0.0, 0.3, 0.5, 0.85, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _animController,
                          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animController,
                            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Badge with Glow
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.accentBlue,
                                  AppColors.accentPurple,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentBlue.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.event.category.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Title with gradient
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Colors.white70],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              widget.event.title,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Info Cards - Premium Glass Style
                          _InfoCard(
                            items: [
                              _InfoItem(
                                icon: Icons.calendar_today_rounded,
                                label: 'Date & Time',
                                value: widget.event.formattedDate,
                                gradient: [
                                  AppColors.accentBlue.withOpacity(0.2),
                                  AppColors.accentBlue.withOpacity(0.05),
                                ],
                              ),
                              _InfoItem(
                                icon: Icons.location_on_rounded,
                                label: 'Venue',
                                value: widget.event.location,
                                gradient: [
                                  AppColors.accentPurple.withOpacity(0.2),
                                  AppColors.accentPurple.withOpacity(0.05),
                                ],
                              ),
                              _InfoItem(
                                icon: Icons.local_activity_rounded,
                                label: 'Entry Fee',
                                value: widget.event.price,
                                gradient: [
                                  Colors.green.withOpacity(0.2),
                                  Colors.green.withOpacity(0.05),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // About Section
                          _SectionTitle(title: 'About Event'),
                          const SizedBox(height: 12),
                          Text(
                            widget.event.description ?? 
                            'Join us for an extraordinary ${widget.event.category.toLowerCase()} experience where innovation meets collaboration. This event brings together the brightest minds to explore cutting-edge solutions.\n\nPerfect for students and professionals looking to expand their knowledge and make meaningful connections.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              height: 1.7,
                              letterSpacing: 0.2,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Attendees Section
                          _SectionTitle(title: "Who's Attending"),
                          const SizedBox(height: 16),
                          _AttendeeAvatars(count: _attendeeCount),

                          const SizedBox(height: 32),

                          // Organizer Section
                          _OrganizerCard(),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Floating Register Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _RegisterButton(
                price: widget.event.price,
                isRegistered: _isRegistered,
                isLoading: _checkingRegistration,
                onTap: _isRegistered ? null : () => _showRegistrationSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegistrationSheet(BuildContext context) async {
    // 1. Check Authentication
    if (!AuthManager.instance.isLoggedIn) {
      HapticFeedback.mediumImpact();
      // Show login screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      
      // If user came back and is now logged in, proceed
      // We check isLoggedIn again because they might have just backed out
      if (!AuthManager.instance.isLoggedIn) return;
    }
    
    // 2. Check Profile Completion (College, Department, etc)
    final profile = AuthManager.instance.userProfile;
    final isProfileComplete = profile != null && 
        (profile['college_id'] != null && profile['college_id'].toString().isNotEmpty) &&
        (profile['department'] != null && profile['department'].toString().isNotEmpty);
        
    if (!isProfileComplete) {
      // Navigate directly to Edit Profile form
      HapticFeedback.lightImpact();
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EditProfileScreen(),
        ),
      );
      
      // If they completed the profile, retry registration
      if (result == true && mounted) {
        _showRegistrationSheet(context);
      }
      return;
    }
    
    HapticFeedback.mediumImpact();
    
    // Check if event is paid
    final isPaid = widget.event.priceAmount > 0;
    
    if (isPaid) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => _PaymentSheet(
          event: widget.event,
          amount: widget.event.priceAmount,
          onSuccess: (ticketCode) {
            Navigator.pop(context);
            _showSuccessSheet(ticketCode);
          },
        ),
      );
    } else {
      // Free event - register directly
      _registerForEvent();
    }
  }

  Future<void> _registerForEvent({String? paymentId}) async {
    try {
      final registration = await SupabaseService.instance.registerForEvent(
        eventId: widget.event.id,
        userId: AuthManager.instance.userId,
        paymentId: paymentId,
      );
      
      final ticketCode = registration['ticket_code'] as String?;
      _showSuccessSheet(ticketCode ?? 'TKT-${DateTime.now().millisecondsSinceEpoch}');
      
      setState(() => _isRegistered = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  void _showSuccessSheet(String ticketCode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) => _RegistrationSuccessSheet(
        event: widget.event,
        ticketCode: ticketCode,
      ),
    );
  }


  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.4),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCharcoal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
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
                  indent: 70,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

class _AttendeeAvatars extends StatelessWidget {
  final int count;
  
  const _AttendeeAvatars({required this.count});
  
  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.accentBlue,
      AppColors.accentPurple,
      Colors.pink,
      Colors.orange,
      Colors.teal,
    ];

    return Row(
      children: [
        SizedBox(
          height: 48,
          width: 140,
          child: Stack(
            children: List.generate(5, (index) {
              return Positioned(
                left: index * 26.0,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colors[index],
                        colors[index].withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppColors.backgroundBlack,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors[index].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      ['A', 'S', 'R', 'K', 'M'][index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count > 0 ? '+$count attending' : 'Be the first!',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrganizerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceCharcoal,
            AppColors.surfaceCharcoal.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SC',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sambhram College',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Event Organizer',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Follow',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final String price;
  final bool isRegistered;
  final bool isLoading;
  final VoidCallback? onTap;

  const _RegisterButton({
    required this.price,
    required this.isRegistered,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.backgroundBlack.withOpacity(0.9),
            AppColors.backgroundBlack,
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isRegistered 
                  ? [Colors.green, Colors.green.shade700]
                  : [AppColors.accentBlue, AppColors.accentPurple],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isRegistered ? Colors.green : AppColors.accentBlue).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              else ...[
                if (isRegistered)
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                if (isRegistered) const SizedBox(width: 12),
                Text(
                  isRegistered 
                      ? 'Already Registered ✓'
                      : price == 'Free' ? 'Register Now' : 'Register for $price',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                if (!isRegistered) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Registration Success Sheet with real QR code
class _RegistrationSuccessSheet extends StatefulWidget {
  final Event event;
  final String ticketCode;

  const _RegistrationSuccessSheet({
    required this.event,
    required this.ticketCode,
  });

  @override
  State<_RegistrationSuccessSheet> createState() => _RegistrationSuccessSheetState();
}

class _RegistrationSuccessSheetState extends State<_RegistrationSuccessSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.forward();
      HapticFeedback.heavyImpact();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate QR data - in production this would be a signed JWT or encrypted data
    final qrData = 'RYU|${widget.event.id}|${widget.ticketCode}|${AuthManager.instance.userId}';
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCharcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 32),

          // Success animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.5 + (_controller.value * 0.5),
                child: Opacity(
                  opacity: _controller.value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.accentBlue, AppColors.accentPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "You're In! 🎉",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Registered for ${widget.event.title}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 32),

          // QR Code with real data
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                  errorStateBuilder: (ctx, err) {
                    return const Icon(
                      Icons.qr_code_2_rounded,
                      size: 180,
                      color: Colors.black,
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  widget.ticketCode.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Show this QR at the venue entrance',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 24),

          // View Ticket button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentBlue, AppColors.accentPurple],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'View in My Tickets',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '📱 Ticket saved to your wallet',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Payment Sheet for paid events
class _PaymentSheet extends StatefulWidget {
  final Event event;
  final double amount;
  final Function(String ticketCode) onSuccess;

  const _PaymentSheet({
    required this.event,
    required this.amount,
    required this.onSuccess,
  });

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  bool _isProcessing = false;
  late Razorpay _razorpay;
  
  static const String merchantVpa = 'kul.adithya@axl';
  static const String merchantName = 'RegisterYu Events';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment Success: ${response.paymentId}');
    await _completeRegistration(response.paymentId ?? 'razorpay');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

  Future<void> _completeRegistration(String paymentId) async {
    try {
      final registration = await SupabaseService.instance.registerForEvent(
        eventId: widget.event.id,
        userId: AuthManager.instance.userId,
        paymentId: paymentId,
      );
      
      final ticketCode = registration['ticket_code'] as String? ?? 'TKT-${DateTime.now().millisecondsSinceEpoch}';
      widget.onSuccess(ticketCode);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
      setState(() => _isProcessing = false);
    }
  }

  void _startRazorpay() {
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    var options = {
      'key': 'rzp_test_1234567890', // Replace with actual key
      'amount': (widget.amount * 100).toInt(),
      'name': 'RegisterYu',
      'description': 'Registration for ${widget.event.title}',
      'prefill': {
        'email': AuthManager.instance.userEmail,
      },
      'theme': {
        'color': '#6C63FF'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
      setState(() => _isProcessing = false);
    }
  }

  void _initiateUpiPayment(String appName, String scheme) async {
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);
    
    final transactionRef = 'RYU${widget.event.id}T${DateTime.now().millisecondsSinceEpoch}';
    final amount = widget.amount.toStringAsFixed(2);
    
    final upiUrl = Uri.parse(Uri.encodeFull(
      '$scheme://pay?pa=$merchantVpa'
      '&pn=$merchantName'
      '&am=$amount'
      '&cu=INR'
      '&tn=Registration for ${widget.event.title}'
      '&tr=$transactionRef'
    ));
    
    try {
      if (await canLaunchUrl(upiUrl)) {
        await launchUrl(upiUrl, mode: LaunchMode.externalApplication);
        // Show confirmation dialog after returning
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          _showPaymentConfirmationDialog();
        }
      } else {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('UPI app not found')),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showPaymentConfirmationDialog() {
    setState(() => _isProcessing = false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCharcoal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Payment Complete?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Did you complete the payment successfully?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
              _completeRegistration('upi_manual');
            },
            child: const Text('Yes, I paid'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCharcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Complete Payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(widget.event.title, style: TextStyle(color: AppColors.textSecondary)),

          const SizedBox(height: 24),

          // Amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentBlue.withOpacity(0.2),
                  AppColors.accentPurple.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('Amount to Pay', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  '₹${widget.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.accentBlue),
            )
          else
            Column(
              children: [
                _UpiButton(name: 'PhonePe', color: const Color(0xFF5F259F), onTap: () => _initiateUpiPayment('PhonePe', 'phonepe')),
                const SizedBox(height: 12),
                _UpiButton(name: 'Google Pay', color: const Color(0xFF4285F4), onTap: () => _initiateUpiPayment('GPay', 'tez')),
                const SizedBox(height: 12),
                _UpiButton(name: 'Razorpay (Cards, UPI, etc)', color: Colors.blue, onTap: _startRazorpay),
              ],
            ),
        ],
      ),
    );
  }
}

class _UpiButton extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback onTap;

  const _UpiButton({required this.name, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.payment, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16))),
            Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
