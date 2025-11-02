import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:traveller/enums/user_enum.dart';
import 'package:traveller/models/user_model.dart';
import 'package:traveller/features/auth/services/auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _socialMediaController = TextEditingController();
  final _yearsOfDrivingController = TextEditingController();
  final _carNameController = TextEditingController();
  final _carModelController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  UserModel? _user;
  Map<String, dynamic>? _detailedData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    _user = await _authService.getCurrentUserData();
    _detailedData = await _authService.getDetailedUserData();

    if (_detailedData != null) {
      _nameController.text = _detailedData!['name'] ?? '';
      _phoneController.text = _detailedData!['phone'] ?? '';
      
      if (_user?.role == UserRole.traveler || _user?.role == UserRole.companier) {
        _socialMediaController.text = _detailedData!['socialMedia'] ?? '';
      }
      
      if (_user?.role == UserRole.traveler) {
        _yearsOfDrivingController.text = (_detailedData!['yearsOfDriving'] ?? 0).toString();
        _carNameController.text = _detailedData!['carName'] ?? '';
        _carModelController.text = _detailedData!['carModel'] ?? '';
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey[800],
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getRoleGradientColors(_user!.role),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(
                      _getRoleIcon(_user!.role),
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRoleDisplayName(_user!.role),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Form
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email (Read-only)
                    _buildTextField(
                      label: 'Email',
                      icon: Icons.email_outlined,
                      value: _user!.email,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // Name
                    _buildTextField(
                      label: 'Full Name',
                      icon: Icons.person_outlined,
                      controller: _nameController,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Social Media (for Traveler and Companier)
                    if (_user!.role == UserRole.traveler || _user!.role == UserRole.companier) ...[
                      _buildTextField(
                        label: 'Social Media Handle',
                        icon: Icons.alternate_email,
                        controller: _socialMediaController,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your social media';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Traveler-specific fields
                    if (_user!.role == UserRole.traveler) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Vehicle Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Years of Driving',
                        icon: Icons.drive_eta,
                        controller: _yearsOfDrivingController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter years of driving';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Car Name',
                        icon: Icons.directions_car,
                        controller: _carNameController,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your car name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Car Model',
                        icon: Icons.car_rental,
                        controller: _carModelController,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your car model';
                          }
                          return null;
                        },
                      ),
                    ],

                    if (_isEditing) ...[
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                });
                                _loadUserData(); // Reload original data
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Colors.grey[400]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blue[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    String? value,
    TextEditingController? controller,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: value,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: enabled ? Colors.grey[800] : Colors.grey[600],
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? Colors.grey[600] : Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      auth.User? currentUser = _authService.getCurrentUser();
      if (currentUser == null) throw Exception('No user logged in');

      // Update based on role
      Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      if (_user!.role == UserRole.traveler || _user!.role == UserRole.companier) {
        updateData['socialMedia'] = _socialMediaController.text.trim();
      }

      if (_user!.role == UserRole.traveler) {
        updateData['yearsOfDriving'] = int.tryParse(_yearsOfDrivingController.text) ?? 0;
        updateData['carName'] = _carNameController.text.trim();
        updateData['carModel'] = _carModelController.text.trim();
      }

      // Update in role-specific collection
      String collection = '';
      switch (_user!.role) {
        case UserRole.admin:
          collection = 'admins';
          break;
        case UserRole.traveler:
          collection = 'travelers';
          break;
        case UserRole.companier:
          collection = 'companiers';
          break;
      }

      await FirebaseFirestore.instance
          .collection(collection)
          .doc(currentUser.uid)
          .update(updateData);

      // Update in users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'name': _nameController.text.trim(),
      });

      // Update display name in Firebase Auth
      await currentUser.updateDisplayName(_nameController.text.trim());

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: Colors.green[600],
        ),
      );

      // Reload data
      await _loadUserData();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  List<Color> _getRoleGradientColors(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [Colors.red[400]!, Colors.red[600]!];
      case UserRole.traveler:
        return [Colors.blue[400]!, Colors.blue[600]!];
      case UserRole.companier:
        return [Colors.teal[400]!, Colors.teal[600]!];
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.traveler:
        return Icons.card_travel;
      case UserRole.companier:
        return Icons.business;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.traveler:
        return 'Traveler';
      case UserRole.companier:
        return 'Companier';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _socialMediaController.dispose();
    _yearsOfDrivingController.dispose();
    _carNameController.dispose();
    _carModelController.dispose();
    super.dispose();
  }
}