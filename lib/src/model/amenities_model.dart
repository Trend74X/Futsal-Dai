import 'package:flutter/material.dart';

class AmenityModel {
  final int id;
  final String label;
  final String iconName;
  bool isSelected;

  AmenityModel({
    required this.id,
    required this.label,
    required this.iconName,
    this.isSelected = false,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: json['id'],
      label: json['label'],
      iconName: json['icon_name'] ?? '',
    );
  }
}

// Icon mapper helper
IconData getAmenityIcon(String iconName) {
  switch (iconName) {
    case 'local_parking':
      return Icons.local_parking;
    case 'shower':
      return Icons.shower;
    case 'light':
      return Icons.light;
    case 'water_drop_outlined':
      return Icons.water_drop_outlined;
    case 'dry_cleaning':
      return Icons.dry_cleaning;
    case 'local_cafe_outlined':
      return Icons.local_cafe_outlined;
    case 'roller_skating':
      return Icons.roller_skating;
    default:
      return Icons.check_circle_outline;
  }
}