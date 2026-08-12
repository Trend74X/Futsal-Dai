class BookingModel {
  final String id;
  final String createdAt;
  final String? deletedAt;
  final String? updatedAt;
  final bool isDeleted;
  final int venueId;
  final String userId;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final double totalPrice;
  final String status;
  final String bookingType;
  final String groundId;
  final String groundName;
  final String? groupId;
  final String venueName;
  final FutsalVenueDetailModel? futsalVenues;

  BookingModel({
    required this.id,
    required this.createdAt,
    this.deletedAt,
    this.updatedAt,
    required this.isDeleted,
    required this.venueId,
    required this.userId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.bookingType,
    required this.groundId,
    required this.groundName,
    this.groupId,
    required this.venueName,
    this.futsalVenues,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      createdAt: json['created_at'] ?? '',
      deletedAt: json['deleted_at'],
      updatedAt: json['updated_at'],
      isDeleted: json['is_deleted'] ?? false,
      venueId: json['venue_id'] ?? 0,
      userId: json['user_id'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      bookingType: json['booking_type'] ?? '',
      groundId: json['ground_id'] ?? '',
      groundName: json['ground_name'] ?? '',
      groupId: json['group_id'],
      venueName: json['venue_name'] ?? '',
      futsalVenues: json['futsal_venues'] != null
          ? FutsalVenueDetailModel.fromJson(json['futsal_venues'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'deleted_at': deletedAt,
      'updated_at': updatedAt,
      'is_deleted': isDeleted,
      'venue_id': venueId,
      'user_id': userId,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'total_price': totalPrice,
      'status': status,
      'booking_type': bookingType,
      'ground_id': groundId,
      'ground_name': groundName,
      'group_id': groupId,
      'venue_name': venueName,
      'futsal_venues': futsalVenues?.toJson(),
    };
  }
}

class FutsalVenueDetailModel {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String? mainImageUrl;

  FutsalVenueDetailModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    this.mainImageUrl,
  });

  factory FutsalVenueDetailModel.fromJson(Map<String, dynamic> json) {
    return FutsalVenueDetailModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      phoneNumber: json['phone_number'] ?? '',
      mainImageUrl: json['main_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'main_image_url': mainImageUrl,
    };
  }
}