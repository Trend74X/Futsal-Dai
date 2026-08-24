import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/owner_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/views/owner/owner_slot_entry.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OwnerSchedulePage extends StatefulWidget {
  const OwnerSchedulePage({super.key}); // Removed required venueId

  @override
  State<OwnerSchedulePage> createState() => _OwnerSchedulePageState();
}

class _OwnerSchedulePageState extends State<OwnerSchedulePage> {
  final OwnerController ownerCon = Get.find<OwnerController>();

  DateTime selectedDateTime = DateTime.now();
  String? selectedGroundId;
  String selectedGroundName = '';
  int? currentVenueId;
  String venueName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Find venueId owned by user, then fetch its grounds automatically
      final venueAndPitches = await ownerCon.fetchVenueAndPitchesByOwner();
      if (venueAndPitches != null) {
        final venue = venueAndPitches['venue'] as Map<String, dynamic>;
        currentVenueId = venue['id'];
        venueName = venue['name'] ?? 'Venue';

        await ownerCon.fetchVenueGrounds(currentVenueId!);
        if (ownerCon.venueGrounds.isNotEmpty) {
          setState(() {
            selectedGroundId = ownerCon.venueGrounds[0]['id'].toString();
            selectedGroundName = ownerCon.venueGrounds[0]['ground_name'] ?? 'Ground';
          });
          _loadTimeline();
        }
      }
    });
  }

  void _loadTimeline() {
    if (selectedGroundId != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDateTime);
      ownerCon.fetchGroundTimelineBookings(
        groundId: selectedGroundId!,
        dateStr: dateStr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dateSelectionWidget(),
                    SizedBox(height: 16.h),
                    pitchesFilterWidget(),
                    SizedBox(height: 16.h),
                    timelineWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dateSelectionWidget() {
    return Container(
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: subtitleTextColor.withValues(alpha: 0.3),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: primaryColor,
            onPrimary: black,
            surface: filledBgColor,
            onSurface: whiteTextColor,
          ),
        ),
        child: CalendarDatePicker(
          initialDate: selectedDateTime,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onDateChanged: (DateTime newDate) {
            setState(() {
              selectedDateTime = newDate;
            });
            _loadTimeline();
          },
        ),
      ),
    );
  }

  Widget pitchesFilterWidget() {
    return Container(
      height: 56.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Obx(() {
        if (ownerCon.isLoadingGrounds.value) {
          return const Center(
            child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor)),
          );
        }
        if (ownerCon.venueGrounds.isEmpty) {
          return Center(child: Text('No pitches available', style: boldStyle(subtitleTextColor, 12.sp)));
        }

        // Auto-select the first ground if not selected yet
        if (selectedGroundId == null && ownerCon.venueGrounds.isNotEmpty) {
          selectedGroundId = ownerCon.venueGrounds[0]['id'].toString();
          selectedGroundName = ownerCon.venueGrounds[0]['ground_name'] ?? 'Ground';
          _loadTimeline();
        }

        return ListView.builder(
          itemCount: ownerCon.venueGrounds.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final ground = ownerCon.venueGrounds[index];
            final String groundId = ground['id'].toString();
            final String groundName = ground['ground_name'] ?? 'Pitch';
            final String groundType = ground['ground_type'] ?? '';
            final bool isSelected = selectedGroundId == groundId;

            return InkWell(
              onTap: () {
                setState(() {
                  selectedGroundId = groundId;
                  selectedGroundName = groundName;
                });
                _loadTimeline();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : transparent,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: Center(
                  child: Text(
                    '$groundName\n$groundType',
                    textAlign: TextAlign.center,
                    style: boldStyle(isSelected ? const Color(0xFF107100) : whiteTextColor, 12.sp),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget timelineWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Obx(() {
        if (ownerCon.isLoadingTimeline.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        bool isToday = DateUtils.isSameDay(selectedDateTime, DateTime.now());
        bool isPastDate = selectedDateTime.isBefore(DateTime.now()) && !isToday;
        int currentHour = DateTime.now().hour;
        List<int> allHours = List.generate(16, (index) => index + 6);
        
        List<int> filteredHours = [];
        if (isPastDate) {
          filteredHours = allHours.where((hour) {
            Map<String, dynamic>? matchingBooking;
            for (var b in ownerCon.groundBookings) {
              final String startStr = b['start_time'] ?? '';
              if (startStr.startsWith(hour.toString().padLeft(2, '0'))) {
                matchingBooking = b;
                break;
              }
            }
            // Keep ONLY if there's an actual booking for past dates
            return matchingBooking != null;
          }).toList();
        } else if (isToday) {
          filteredHours = allHours.where((hour) {
            final String timeFormatted = '${hour.toString().padLeft(2, '0')}:00';
            Map<String, dynamic>? matchingBooking;
            for (var b in ownerCon.groundBookings) {
              final String startStr = b['start_time'] ?? '';
              if (startStr.startsWith(hour.toString().padLeft(2, '0'))) {
                matchingBooking = b;
                break;
              }
            }
            // Keep if it's current/future hour OR if there's an actual booking in the past hour today
            return hour >= currentHour || matchingBooking != null;
          }).toList();
        } else {
          filteredHours = allHours;
        }

        if (filteredHours.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No remaining time slots for today.',
                style: boldStyle(subtitleTextColor, 12.sp),
              ),
            ),
          );
        }

        return Column(
          children: filteredHours.map((hour) {
            final String timeFormatted = '${hour.toString().padLeft(2, '0')}:00';
            final String displayTimeLabel = DateFormat('h:a').format(DateTime(0, 1, 1, hour));

            Map<String, dynamic>? matchingBooking;
            for (var b in ownerCon.groundBookings) {
              final String startStr = b['start_time'] ?? '';
              if (startStr.startsWith(hour.toString().padLeft(2, '0'))) {
                matchingBooking = b;
                break;
              }
            }

            String status = 'AVAILABLE';
            String? subtitle;

            if (matchingBooking != null) {
              final String dbStatus = matchingBooking['status'] ?? 'booked';
              final String teamName = matchingBooking['team_name'] ?? 
                                     matchingBooking['users']?['full_name'] ?? 
                                     'Reserved';
              final String bookingType = matchingBooking['booking_type'] ?? '';

              if (dbStatus == 'booked' || dbStatus == 'confirmed') {
                status = bookingType == 'by_phone_call' ? 'Offline' : 'Booked';
                
                // Update subtitle based on booking type for offline/manual bookings
                if (bookingType == 'by_phone_call') {
                  subtitle = 'Phone Call';
                } else if (bookingType == 'manual_walk_in') {
                  subtitle = 'Manual Walk-In';
                } else {
                  subtitle = teamName;
                }
              } else if (dbStatus == 'completed') {
                status = 'Completed';
                subtitle = teamName;
              } else if (dbStatus == 'in_progress') {
                status = 'IN PROGESS';
                subtitle = teamName;
              } else if (dbStatus == 'cancelled' || dbStatus == 'rejected') {
                status = 'Cancelled';
                subtitle = teamName;
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: timeLineTile(
                time: displayTimeLabel,
                status: status,
                subtitle: subtitle,
                onTapAvailable: () async {
                  if (currentVenueId == null) {
                    // Fallback: fetch venue info directly if currentVenueId hasn't loaded yet
                    final venueAndPitches = await ownerCon.fetchVenueAndPitchesByOwner();
                    if (venueAndPitches != null) {
                      final venue = venueAndPitches['venue'] as Map<String, dynamic>;
                      currentVenueId = venue['id'];
                    } else {
                      Get.snackbar('Error', 'Venue information not found', backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                  }

                  final venueRes = await ownerCon.supabase
                      .from('futsal_venues')
                      .select('name, base_price, is_peak_enabled, peak_start_time, peak_end_time, peak_rate')
                      .eq('id', currentVenueId!)
                      .maybeSingle();

                  final currentGround = ownerCon.venueGrounds.firstWhere(
                    (g) => g['id'].toString() == selectedGroundId,
                    orElse: () => {},
                  );

                  String venueName = venueRes?['name'] ?? 'Venue';
                  double basePrice = double.tryParse(venueRes?['base_price']?.toString() ?? '1500.0') ?? 1500.0;
                  double peakRate = double.tryParse(venueRes?['peak_rate']?.toString() ?? '0.0') ?? 0.0;
                  bool isPeakEnabled = venueRes?['is_peak_enabled'] ?? false;
                  String? peakStart = venueRes?['peak_start_time'];
                  String? peakEnd = venueRes?['peak_end_time'];
                  double groundModifier = double.tryParse(currentGround['price_modifier']?.toString() ?? '0.0') ?? 0.0;

                  final parts = timeFormatted.split(':');
                  int hour = int.parse(parts[0]);
                  DateTime targetDateTime = DateTime(
                    selectedDateTime.year, // Uses the date selected on your calendar picker
                    selectedDateTime.month,
                    selectedDateTime.day,
                    hour,
                    0,
                  );

                  Get.to(() => OwnerMaunualSlotEntry(
                    venueId: currentVenueId!,
                    venueName: venueName,
                    venueGrounds: ownerCon.venueGrounds,
                    initialGroundId: selectedGroundId,
                    initialGroundName: selectedGroundName,
                    initialTimeSlot: DateFormat('yyyy-MM-dd HH:mm:ss').format(targetDateTime),
                    basePrice: basePrice,
                    peakRate: peakRate,
                    isPeakEnabled: isPeakEnabled,
                    peakStartTime: peakStart,
                    peakEndTime: peakEnd,
                    groundModifier: groundModifier,
                  ));
                },
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget dividerWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(child: Container(color: const Color(0xFF85967C), height: 1.h)),
          SizedBox(width: 8.w),
          Text('EVENING SESSIONS', style: regularStyle(const Color(0xFF85967C), 10.sp)),
          SizedBox(width: 8.w),
          Expanded(child: Container(color: const Color(0xFF85967C), height: 1.h)),
        ],
      ),
    );
  }

  Widget timeLineTile({
    required String time,
    required String status,
    String? subtitle,
    VoidCallback? onTapAvailable,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            time,
            style: boldStyle(status == 'Completed' ? gray02 : subtitleTextColor, 12.sp),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 6,
          child: Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: getContainerColor(status: status),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: subtitleTextColor.withValues(alpha: 0.5)),
            ),
            child: status == 'AVAILABLE'
                ? InkWell(
                    onTap: onTapAvailable,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: subtitleTextColor),
                        Text(
                          status,
                          style: boldStyle(subtitleTextColor, 12.sp),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: double.infinity,
                        color: getInnerContainerColor(status: status),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status == 'Offline' ? 'Offline/Call/Walk-In' : status,
                            style: boldStyle(status == 'IN PROGESS' ? primaryColor : whiteTextColor, 12.sp),
                          ),
                          subtitle == null
                              ? const SizedBox()
                              : Text(
                                subtitle,
                                style: boldStyle(subtitleTextColor, 10.sp),
                              ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Color getContainerColor({required String status}) {
    return status == 'AVAILABLE'
        ? transparent
        : status == 'Completed'
            ? lightFilledBgColor
            : status == 'IN PROGESS'
                ? primaryColor.withValues(alpha: 0.2)
                : status == 'Offline'
                    ? gray01
                    : status == 'Cancelled'
                        ? const Color(0xFF93000A).withValues(alpha: 0.1)
                        : filledBgColor;
  }

  Color getInnerContainerColor({required String status}) {
    return status == 'Completed'
        ? subtitleTextColor
        : status == 'IN PROGESS'
            ? primaryColor
            : status == 'Offline'
                ? gray01
                : status == 'Cancelled'
                    ? const Color(0xFF93000A).withValues(alpha: 0.3)
                    : textBlue;
  }
}