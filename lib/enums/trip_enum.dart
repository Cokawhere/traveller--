// lib/enums/trip_enum.dart

enum TripStatus {
  pendingApproval,
  approved,
  rejected,
  inProgress,
  completed,
  cancelled,
}

extension TripStatusExtension on TripStatus {
  String get displayName {
    switch (this) {
      case TripStatus.pendingApproval:
        return 'Pending Approval';
      case TripStatus.approved:
        return 'Approved';
      case TripStatus.rejected:
        return 'Rejected';
      case TripStatus.inProgress:
        return 'In Progress';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get firebaseValue {
    switch (this) {
      case TripStatus.pendingApproval:
        return 'pending_approval';
      case TripStatus.approved:
        return 'approved';
      case TripStatus.rejected:
        return 'rejected';
      case TripStatus.inProgress:
        return 'in_progress';
      case TripStatus.completed:
        return 'completed';
      case TripStatus.cancelled:
        return 'cancelled';
    }
  }

  static TripStatus fromString(String status) {
    switch (status) {
      case 'pending_approval':
      case 'pendingApproval':
        return TripStatus.pendingApproval;
      case 'approved':
        return TripStatus.approved;
      case 'rejected':
        return TripStatus.rejected;
      case 'in_progress':
      case 'inProgress':
        return TripStatus.inProgress;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.pendingApproval;
    }
  }
}