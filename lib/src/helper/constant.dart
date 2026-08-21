import 'package:flutter/material.dart';
import 'package:futsal_dai/src/model/day_schedule_model.dart';

const String supabaseUrl = 'https://gilwmzglondlmruasdwj.supabase.co';
const String supabasePublishablekey = 'sb_publishable_Rvcts_U8z98jD8lOqWXXNw_wY2e316Z';
const String supabaseBearerToken = 'sb_publishable_Rvcts_U8z98jD8lOqWXXNw_wY2e316Z';


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


  List<DaySchedule> individualDays = [
    DaySchedule(dayOfWeek: 0, label: 'Sunday'),
    DaySchedule(dayOfWeek: 1, label: 'Monday'),
    DaySchedule(dayOfWeek: 2, label: 'Tuesday'),
    DaySchedule(dayOfWeek: 3, label: 'Wednesday'),
    DaySchedule(dayOfWeek: 4, label: 'Thursday'),
    DaySchedule(dayOfWeek: 5, label: 'Friday'),
    DaySchedule(dayOfWeek: 6, label: 'Saturday'),
  ];

  List<DaySchedule> groupedDays = [
    DaySchedule(dayOfWeek: null, label: 'Mon - Fri'),
    DaySchedule(dayOfWeek: 6, label: 'Saturday', isEnabled: false),
    DaySchedule(dayOfWeek: 0, label: 'Sunday', isEnabled: false),
  ];