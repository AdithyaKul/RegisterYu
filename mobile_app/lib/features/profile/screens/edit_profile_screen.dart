import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/auth_manager.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel? user;

  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usnController;
  late TextEditingController _phoneController;
  late TextEditingController _deptController;
  late TextEditingController _semController;
  late TextEditingController _sectionController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user ?? AuthManager.instance.currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _usnController = TextEditingController(text: user?.usn ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _deptController = TextEditingController(text: user?.department ?? '');
    _semController = TextEditingController(text: user?.semester ?? '');
    _sectionController = TextEditingController(text: user?.section ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usnController.dispose();
    _phoneController.dispose();
    _deptController.dispose();
    _semController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updates = {
        'full_name': _nameController.text.trim(),
        'usn': _usnController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'department': _deptController.text.trim(),
        'semester': _semController.text.trim(),
        'section': _sectionController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await SupabaseService.instance.updateProfile(
        AuthManager.instance.userId, 
        updates
      );
      
      // Update local state in AuthManager if needed
      // await AuthManager.instance.refreshProfile(); // Assuming this exists or needed

      if (mounted) {
        SuccessSnackBar.show(context, 'Profile updated successfully');
        Navigator.pop(context, true); // Return true to indicate update
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, 'Failed to update profile: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Personal Details'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_rounded,
                validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
               _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('College Details'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usnController,
                label: 'USN (University Seat No)',
                icon: Icons.badge_rounded,
                validator: (v) => v?.isEmpty == true ? 'USN is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _deptController,
                label: 'Department (e.g. CSE)',
                icon: Icons.school_rounded,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _semController,
                      label: 'Semester',
                      icon: Icons.calendar_view_day_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _sectionController,
                      label: 'Section',
                      icon: Icons.class_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.accentBlue,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceCharcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentBlue),
        ),
      ),
    );
  }
}

class SuccessSnackBar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ErrorSnackBar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
