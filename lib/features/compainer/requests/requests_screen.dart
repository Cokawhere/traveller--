// lib/screens/companion_my_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:traveller/features/compainer/evaluation/evaluation_dialog.dart'
    show showEvaluationDialog;
import 'requests_controller.dart';

class CompanionMyRequestsScreen extends StatelessWidget {
  CompanionMyRequestsScreen({super.key});

  final CompanionMyRequestsController controller =
      Get.put(CompanionMyRequestsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        title: Text(
          'My Requests',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.blue));
              }

              if (controller.filteredRequests.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadRequests(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredRequests.length,
                  itemBuilder: (context, index) {
                    final request = controller.filteredRequests[index];
                    return _buildRequestCard(request, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: [
                _buildFilterChip('All', 'all', controller.selectedFilter.value),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Pending', 'pending', controller.selectedFilter.value),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Accepted', 'accepted', controller.selectedFilter.value),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Rejected', 'rejected', controller.selectedFilter.value),
              ],
            )),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedFilter) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        controller.selectedFilter.value = value;
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue[600],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, BuildContext context) {
    final status = request['status'];
    final statusColor = _getStatusColor(status);
    final createdAt = DateTime.parse(request['createdAt']);
    final isAccepted = status == 'accepted';

    // ✅ Check if trip is completed (past time)
    final tripTime = DateTime.parse(request['tripData']['time']);
    final isTripCompleted = tripTime.isBefore(DateTime.now());

    // تنسيق التاريخ
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final formattedDate = dateFormat.format(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🆕 HEADER: Status Badge + Trip Title + Date
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Trip Title (Origin -> Destination)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${request['tripData']['origin']} → ${request['tripData']['destination']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Trip Time: ${DateFormat('MMM dd, yyyy • hh:mm a').format(tripTime)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Date
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // 🆕 TRIP INFO: Traveler Name + Description (اختياري)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Traveler Name
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Traveler: ${request['tripData']['travelerName']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Quick Description (لو موجود في tripData، أو اجعليه optional)
                if (request['message'] != null &&
                    request['message'].isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.message, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Message: ${request['message']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                const Divider(),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Request Details (الجزء الأساسي، مع phone إذا accepted)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show phone number only if accepted
                if (isAccepted &&
                    request['tripData']?['phoneNumber'] != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.phone, color: Colors.green[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Driver Phone',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                request['tripData']['phoneNumber'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Action buttons (الجزء السفلي زي ما هو)
          if (isAccepted)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // ⭐ Show evaluation button only if trip is completed
                  if (isTripCompleted) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEvaluationDialog(request),
                        icon: const Icon(Icons.star, size: 20),
                        label: const Text('Rate This Trip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Contact & Location buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.callTraveler(
                              request['tripData']?['phoneNumber']),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green[600],
                            side: BorderSide(color: Colors.green[600]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              controller.viewLocation(request['tripId']),
                          icon: const Icon(Icons.location_on, size: 18),
                          label: const Text('Location'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[600],
                            side: BorderSide(color: Colors.red[600]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          controller.viewTripDetails(request['tripId']),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Trip Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[600],
                        side: BorderSide(color: Colors.blue[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

// ⭐ Add this method to show evaluation dialog
 void _showEvaluationDialog(Map<String, dynamic> request) {
  showEvaluationDialog(
    tripId: request['tripId'],
    travelerId: request['tripData']['travelerId'],
    travelerName: request['tripData']['travelerName'],
    evaluatorId: controller.userId.toString(),   // لازم يكون عندك الcurrent user ID
    evaluatorName: controller.userName.toString(), // نفس الشيء
  );
}

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No requests yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse trips and send join requests',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
