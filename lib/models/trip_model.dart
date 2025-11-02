import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:traveller/enums/trip_enum.dart';

class TripModel {
  final String tripId;
  final String travelerId;
  final String travelerName;
  final String origin;
  final String destination;
  final DateTime time;
  final String description;
  final int availableSeats;
  final double pricePerSeat;
  final TripStatus status;
  final String? adminId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;
  
  // Car information
  final String carName;
  final String carModel;
  
  // Contact information
  final String phoneNumber;
  
  // Additional preferences
  final bool allowSmoking;
  final bool allowPets;
  final String? additionalNotes;

  // Companions list
  final List<Map<String, dynamic>> companions;
  final int totalSeatsBooked;
  
  // 📍 Location tracking
  final double? currentLat;
  final double? currentLng;
  final DateTime? lastLocationUpdate;

  TripModel({
    required this.tripId,
    required this.travelerId,
    required this.travelerName,
    required this.origin,
    required this.destination,
    required this.time,
    required this.description,
    required this.availableSeats,
    required this.pricePerSeat,
    required this.status,
    this.adminId,
    required this.createdAt,
    this.updatedAt,
    this.isEdited = false,
    required this.carName,
    required this.carModel,
    required this.phoneNumber,
    this.allowSmoking = false,
    this.allowPets = false,
    this.additionalNotes,
    this.companions = const [],
    this.totalSeatsBooked = 0,
    this.currentLat,
    this.currentLng,
    this.lastLocationUpdate,
  });

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'travelerId': travelerId,
      'travelerName': travelerName,
      'origin': origin,
      'destination': destination,
      'time': time.toIso8601String(),
      'description': description,
      'availableSeats': availableSeats,
      'pricePerSeat': pricePerSeat,
      'status': status.firebaseValue,
      'adminId': adminId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isEdited': isEdited,
      'carName': carName,
      'carModel': carModel,
      'phoneNumber': phoneNumber,
      'allowSmoking': allowSmoking,
      'allowPets': allowPets,
      'additionalNotes': additionalNotes,
      'companions': companions,
      'totalSeatsBooked': totalSeatsBooked,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'lastLocationUpdate': lastLocationUpdate?.toIso8601String(),
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      tripId: map['tripId'] ?? '',
      travelerId: map['travelerId'] ?? '',
      travelerName: map['travelerName'] ?? '',
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      time: DateTime.parse(map['time'] ?? DateTime.now().toIso8601String()),
      description: map['description'] ?? '',
      availableSeats: map['availableSeats'] ?? 1,
      pricePerSeat: (map['pricePerSeat'] ?? 0.0).toDouble(),
      status: TripStatusExtension.fromString(map['status'] ?? 'pending_approval'),
      adminId: map['adminId'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isEdited: map['isEdited'] ?? false,
      carName: map['carName'] ?? '',
      carModel: map['carModel'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      allowSmoking: map['allowSmoking'] ?? false,
      allowPets: map['allowPets'] ?? false,
      additionalNotes: map['additionalNotes'],
      companions: List<Map<String, dynamic>>.from(map['companions'] ?? []),
      totalSeatsBooked: map['totalSeatsBooked'] ?? 0,
      currentLat: map['currentLat']?.toDouble(),
      currentLng: map['currentLng']?.toDouble(),
      lastLocationUpdate: map['lastLocationUpdate'] != null 
          ? DateTime.parse(map['lastLocationUpdate']) 
          : null,
    );
  }

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TripModel.fromMap(data);
  }

  // Copy with method for editing
  TripModel copyWith({
    String? tripId,
    String? travelerId,
    String? travelerName,
    String? origin,
    String? destination,
    DateTime? time,
    String? description,
    int? availableSeats,
    double? pricePerSeat,
    TripStatus? status,
    String? adminId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    String? carName,
    String? carModel,
    String? phoneNumber,
    bool? allowSmoking,
    bool? allowPets,
    String? additionalNotes,
    List<Map<String, dynamic>>? companions,
    int? totalSeatsBooked,
    double? currentLat,
    double? currentLng,
    DateTime? lastLocationUpdate,
  }) {
    return TripModel(
      tripId: tripId ?? this.tripId,
      travelerId: travelerId ?? this.travelerId,
      travelerName: travelerName ?? this.travelerName,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      time: time ?? this.time,
      description: description ?? this.description,
      availableSeats: availableSeats ?? this.availableSeats,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      status: status ?? this.status,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      carName: carName ?? this.carName,
      carModel: carModel ?? this.carModel,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      allowSmoking: allowSmoking ?? this.allowSmoking,
      allowPets: allowPets ?? this.allowPets,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      companions: companions ?? this.companions,
      totalSeatsBooked: totalSeatsBooked ?? this.totalSeatsBooked,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    );
  }
}