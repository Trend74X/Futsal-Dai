class FutsalVenueModel {
  final int id;
  final DateTime? createdAt;
  final DateTime? deletedAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final String? ownerId;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> amenities;
  final bool isVerified;
  final String? phoneNumber;
  final String? address;
  final String? description;
  final String? mainImageUrl;
  final List<String> galleryImageUrls;
  final double basePrice;
  final int slotDurationMins;
  final int bufferTimeMins;
  final bool isPeakEnabled;
  final String? peakStartTime;
  final String? peakEndTime;
  final double? peakRate;
  final double distanceKm;

  FutsalVenueModel({
    required this.id,
    this.createdAt,
    this.deletedAt,
    this.updatedAt,
    required this.isDeleted,
    this.ownerId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.amenities,
    required this.isVerified,
    this.phoneNumber,
    this.address,
    this.description,
    this.mainImageUrl,
    required this.galleryImageUrls,
    required this.basePrice,
    required this.slotDurationMins,
    required this.bufferTimeMins,
    required this.isPeakEnabled,
    this.peakStartTime,
    this.peakEndTime,
    this.peakRate,
    required this.distanceKm,
  });

  factory FutsalVenueModel.fromJson(Map<String, dynamic> json) {
    return FutsalVenueModel(
      id: json['id'] as int,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      isDeleted: json['is_deleted'] ?? false,
      ownerId: json['owner_id']?.toString(),
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      amenities: _parseArray(json['amenities']),
      isVerified: json['is_verified'] ?? false,
      phoneNumber: json['phone_number']?.toString(),
      address: json['address']?.toString(),
      description: json['description']?.toString(),
      mainImageUrl: json['main_image_url']?.toString(),
      galleryImageUrls: _parseArray(json['gallery_image_urls']),
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      slotDurationMins: (json['slot_duration_mins'] as num?)?.toInt() ?? 60,
      bufferTimeMins: (json['buffer_time_mins'] as num?)?.toInt() ?? 0,
      isPeakEnabled: json['is_peak_enabled'] ?? false,
      peakStartTime: json['peak_start_time']?.toString(),
      peakEndTime: json['peak_end_time']?.toString(),
      peakRate: json['peak_rate'] != null ? (json['peak_rate'] as num).toDouble() : null,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'owner_id': ownerId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'amenities': amenities,
      'is_verified': isVerified,
      'phone_number': phoneNumber,
      'address': address,
      'description': description,
      'main_image_url': mainImageUrl,
      'gallery_image_urls': galleryImageUrls,
      'base_price': basePrice,
      'slot_duration_mins': slotDurationMins,
      'buffer_time_mins': bufferTimeMins,
      'is_peak_enabled': isPeakEnabled,
      'peak_start_time': peakStartTime,
      'peak_end_time': peakEndTime,
      'peak_rate': peakRate,
      'distance_km': distanceKm,
    };
  }

  /// Helper to convert standard List or Postgres Array strings (e.g. `{Parking,Showers}`) into List<String>
  static List<String> _parseArray(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      // Handles Postgres array formatted string like '{Parking,Showers,"Night Light"}'
      String cleanStr = value.replaceAll('{', '').replaceAll('}', '').replaceAll('"', '');
      if (cleanStr.trim().isEmpty) return [];
      return cleanStr.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }
}