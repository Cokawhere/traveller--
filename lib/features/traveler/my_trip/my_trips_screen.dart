// lib/features/trips/screens/my_trips_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traveller/models/trip_model.dart';
import 'package:traveller/enums/trip_enum.dart';
import 'package:intl/intl.dart';

import 'my_trips_controller.dart';

class MyTripsScreen extends StatelessWidget {
  MyTripsScreen({super.key});

  final MyTripsController controller = Get.put(MyTripsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        title: Text(
          'My Trips',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredTrips.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadTrips(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredTrips.length,
                  itemBuilder: (context, index) {
                    final trip = controller.filteredTrips[index];
                    return _buildTripCard(trip, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.navigateToCreateTrip(),
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: 'Search trips...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => controller.searchQuery.value = '',
                )
              : const SizedBox()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
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
                    'Active', 'active', controller.selectedFilter.value),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Completed', 'completed', controller.selectedFilter.value),
                const SizedBox(width: 8),
                _buildFilterChip(
                    'Pending', 'pending', controller.selectedFilter.value),
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

  Widget _buildTripCard(TripModel trip, BuildContext context) {
    final statusColor = _getStatusColor(trip.status);
    final isCompleted = trip.status == TripStatus.completed ||
        trip.status == TripStatus.cancelled;
    final isApproved = trip.status == TripStatus.approved;
    final canEdit = trip.status == TripStatus.approved ||
        trip.status == TripStatus.rejected ||
        trip.status == TripStatus.pendingApproval;

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
          // Header with status badge
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trip.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // ✅ Show requests count for approved trips
                if (isApproved)
                  FutureBuilder<int>(
                    future: controller.getRequestsCount(trip.tripId),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      if (count > 0) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange[600],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                '$count Request${count > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                if (trip.isEdited)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 14, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Edited',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Trip details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip.origin,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.arrow_downward,
                      color: Colors.grey[400], size: 20),
                ),
                Row(
                  children: [
                    Icon(Icons.flag, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip.destination,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Info row
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.calendar_today,
                      DateFormat('MMM dd, yyyy').format(trip.time),
                    ),
                    const SizedBox(width: 16),
                    _buildInfoItem(
                      Icons.access_time,
                      DateFormat('hh:mm a').format(trip.time),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.airline_seat_recline_normal,
                      '${trip.availableSeats} seats',
                    ),
                    const SizedBox(width: 16),
                    _buildInfoItem(
                      Icons.attach_money,
                      '${trip.pricePerSeat.toStringAsFixed(0)} ',
                    ),
                  ],
                ),

                // ✅ Show companions count
                if (trip.companions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    Icons.people,
                    '${trip.companions.length} Companion${trip.companions.length > 1 ? 's' : ''}',
                    color: Colors.green[600],
                  ),
                ],

                if (trip.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    trip.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          if (!isCompleted)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  if (canEdit) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.editTrip(trip),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[600],
                          side: BorderSide(color: Colors.blue[600]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteDialog(context, trip),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        side: BorderSide(color: Colors.red[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.viewTripDetails(trip),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
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

  Widget _buildInfoItem(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: color ?? Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.pendingApproval:
        return Colors.orange;
      case TripStatus.approved:
        return Colors.green;
      case TripStatus.rejected:
        return Colors.red;
      case TripStatus.inProgress:
        return Colors.blue;
      case TripStatus.completed:
        return Colors.grey;
      case TripStatus.cancelled:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_travel,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No trips found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first trip to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.navigateToCreateTrip(),
            icon: const Icon(Icons.add),
            label: const Text('Create Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TripModel trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600]),
              const SizedBox(width: 8),
              const Text('Delete Trip'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this trip?\n\n${trip.origin} → ${trip.destination}\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteTrip(trip.tripId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}