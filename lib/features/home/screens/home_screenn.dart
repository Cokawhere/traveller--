// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traveller/enums/user_enum.dart';
import 'package:traveller/features/home/logic/home_controller.dart';
import 'package:traveller/models/user_model.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading indicator while fetching user data
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.blue)),
        );
      }

      // Show error if user data is null
      if (controller.currentUser.value == null) {
        return const Scaffold(
          body: Center(child: Text('Failed to load user data')),
        );
      }

      UserModel user = controller.currentUser.value!;

      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey[800]),
          title: Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.grey[800]),
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
        drawer: _buildDrawer(context, user),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(user),
              const SizedBox(height: 32),
              _buildAccountInfoSection(user),
              const SizedBox(height: 32),
              // _buildRecentActivitySection(),
            ],
          ),
        ),
      );
    });
  }

  // Welcome Card Widget
  Widget _buildWelcomeCard(UserModel user) {
    final colors = controller.getRoleGradientColors(user.role);
    final iconCode = controller.getRoleIconCode(user.role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(colors[0]), Color(colors[1])],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconCode,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${controller.getRoleDisplayName(user.role)} Account',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Account Information Section
  Widget _buildAccountInfoSection(UserModel user) {
    final iconCode = controller.getRoleIconCode(user.role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard('Email', user.email, Icons.email_outlined),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Role',
          controller.getRoleDisplayName(user.role),
          iconCode,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Account Type',
          controller.getRoleDescription(user.role),
          Icons.info_outlined,
        ),
      ],
    );
  }

  // Info Card Widget
  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
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

  // Recent Activity Section
  // Widget _buildRecentActivitySection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Recent Activity',
  //         style: TextStyle(
  //           fontSize: 20,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.grey[800],
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       // _buildActivityCard(),
  //     ],
  //   );
  // }

  // Activity Card Widget
  // Widget _buildActivityCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         Icon(Icons.upcoming, size: 48, color: Colors.grey[400]),
  //         const SizedBox(height: 12),
  //         Text(
  //           'No recent activity',
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: Colors.grey[600],
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           'Your activities will appear here',
  //           style: TextStyle(fontSize: 14, color: Colors.grey[500]),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Drawer Widget
  Widget _buildDrawer(BuildContext context, UserModel user) {
    final colors = controller.getRoleGradientColors(user.role);
    final iconCode = controller.getRoleIconCode(user.role);

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(colors[0]), Color(colors[1])],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Icon(
                    iconCode,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.getRoleDisplayName(user.role),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.blue[600]),
                  title: const Text(
                    'My Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Get.back();
                    controller.navigateToProfile();
                  },
                ),
                const Divider(
                    height: 24, thickness: 1, indent: 16, endIndent: 16),
                ..._buildRoleSpecificMenuItems(user.role),
                const Divider(height: 32, thickness: 1),
                // _buildCommonMenuItem(
                //   Icons.settings,
                //   'Settings',
                //   () {
                //     Get.back();
                //     Get.snackbar(
                //         'Coming Soon', 'Settings page is under development.');
                //   },
                // ),
                // _buildCommonMenuItem(
                //   Icons.help_outline,
                //   'Help & Support',
                //   () {
                //     Get.back();
                //     Get.snackbar('Coming Soon',
                //         'Help & Support page is under development.');
                //   },
                // ),
                _buildCommonMenuItem(
                  Icons.info_outline,
                  'About',
                  () {
                    Get.back();
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          const Divider(height: 1, thickness: 1),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[600]),
            title: Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red[600],
              ),
            ),
            onTap: () {
              Get.back();
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Build Role-Specific Menu Items
  List<Widget> _buildRoleSpecificMenuItems(UserRole role) {
    final items = controller.getRoleSpecificMenuItems(role);
    return items.map((item) {
      final badge = item['badge'];
      return ListTile(
        leading: Icon(
          item['icon'],
          color: Color(item['color']),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item['title'],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            if (badge != null && badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          Get.back();
          controller.navigateToRoute(item['route']);
        },
      );
    }).toList();
  }

  // Build Common Menu Item
  Widget _buildCommonMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  // Show Logout Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Show About Dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Text('About'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Traveller App',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Version 1.0.0'),
              const SizedBox(height: 16),
              Text(
                'A companion travel app connecting travelers with companions for safer journeys.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
