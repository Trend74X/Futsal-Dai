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


List pastMatches = [
  {
    "label": "Prismatic Futsal & Recreation Center",
    "date": "Dec 10, 2025",
    "amount": "1200",
    "status": "completed"
  },
  {
    "label": "X-Arena Pro",
    "date": "Dec 10, 2025",
    "amount": "0",
    "status": "cancelled (refunded)"
  },
];


List transactions = [
  {
    "date": "DECEMBER 2026",
    "data": [
      {
        "name": "Prismatic Futsal & Recreation Center",
        "date": "Dec 16, 2026",
        "time": "8:00 PM",
        "price": "1200",
        "status": "SUCCESSFUL"
      },
      {
        "name": "Neon Turf Central",
        "date": "Dec 04, 2026",
        "time": "10:00 PM",
        "price": "1800",
        "status": "REFUNDED"
      }
    ]
  },
  {
    "date": "NOVEMBER 2026",
    "data": [
      {
        "name": "Urban Kick Arena",
        "date": "Nov 25, 2026",
        "time": "6:00 PM",
        "price": "1450",
        "status": "SUCCESSFUL"
      },
      {
        "name": "Pro-Fit Futsal Hub",
        "date": "Nov 18, 2026",
        "time": "9:00 PM",
        "price": "1200",
        "status": "SUCCESSFUL"
      },
      {
        "name": "X-Arena",
        "date": "Nov 11, 2026",
        "time": "6:00 PM",
        "price": "1500",
        "status": "SUCCESSFUL"
      },
      {
        "name": "Creative Futsal Hub",
        "date": "Nov 4, 2026",
        "time": "9:00 PM",
        "price": "1000",
        "status": "SUCCESSFUL"
      }
    ]
  }
];


List favoritesStalls = [
  {
    "name": "Prismatic Futsal & Recreation Center",
    "location": "Sanepa, Lalitpur, Nepal",
    "price": "1500",
    "isFav": true
  },
  {
    "name": "X-Arena Pro",
    "location": "Downtown District, Sector 7",
    "price": "45",
    "isFav": true
  },
  {
    "name": "Neon Roof Pitch",
    "location": "Skyline Plaza, East Side",
    "price": "60",
    "isFav": true
  },
  {
    "name": "Underground Futsal",
    "location": "The Vault, Old Industrial Park",
    "price": "35",
    "isFav": true
  }
];