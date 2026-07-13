import 'package:flutter/material.dart';

List amenities = [
  {
    'label' : 'Parking',
    'icon': Icons.local_parking,
    'isSelected': false,
  },
  {
    'label' : 'Showers',
    'icon': Icons.shower,
    'isSelected': false,
  },
  {
    'label' : 'Night Light',
    'icon': Icons.light,
    'isSelected': false,
  },
  {
    'label' : 'Drinking Water',
    'icon': Icons.water_drop_outlined,
    'isSelected': false,
  },
  {
    'label' : 'Bibs',
    'icon': Icons.dry_cleaning,
    'isSelected': false,
  },
  {
    'label' : 'Cafe',
    'icon': Icons.local_cafe_outlined,
    'isSelected': false,
  },
  {
    'label' : 'Shoes Rental',
    'icon': Icons.roller_skating,
    'isSelected': false,
  }
];


List slots = [
  {
    "slot": "06:00 - 07:00",
    "status": "available",
    "price": 1200,
    "is_peak_hour": false,
    "booked_by": ""
  },
  {
    "slot": "07:00 - 08:00",
    "status": "booked",
    "price": 1200,
    "is_peak_hour": false,
    "booked_by": "Ashok & Vai ko Team"
  },
  {
    "slot": "08:00 - 09:00",
    "status": "pending",
    "price": 1200,
    "is_peak_hour": false,
    "booked_by": ""
  },
  {
    "slot": "09:00 - 10:00",
    "status": "available",
    "price": 1200,
    "is_peak_hour": false,
    "booked_by": ""
  },
  {
    "slot": "10:00 - 11:00",
    "status": "available",
    "price": 1200,
    "is_peak_hour": false,
    "booked_by": ""
  },
  {
    "slot": "04:00 - 05:00",
    "status": "available",
    "price": 1500,
    "is_peak_hour": false,
    "booked_by": ""
  },
  {
    "slot": "05:00 - 06:00",
    "status": "booked",
    "price": 1500,
    "is_peak_hour": false,
    "booked_by": "Miracle Team"
  },
  {
    "slot": "06:00 - 07:00",
    "status": "available",
    "price": 1500,
    "is_peak_hour": true,
    "booked_by": ""
  },
  {
    "slot": "07:00 - 08:00",
    "status": "pending",
    "price": 1500,
    "is_peak_hour": true,
    "booked_by": ""
  },
  {
    "slot": "08:00 - 09:00",
    "status": "available",
    "price": 1500,
    "is_peak_hour": true,
    "booked_by": ""
  }
];