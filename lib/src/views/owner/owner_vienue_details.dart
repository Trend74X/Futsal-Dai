import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/app_controller.dart';
import 'package:futsal_dai/src/controller/owner_controller.dart';
import 'package:futsal_dai/src/helper/cache_manager.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/validators.dart';
import 'package:futsal_dai/src/model/amenities_model.dart';
import 'package:futsal_dai/src/model/pitch_model.dart';
import 'package:futsal_dai/src/widgets/custom_map.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class OwnerVenueDetails extends StatefulWidget {
  const OwnerVenueDetails({super.key});

  @override
  State<OwnerVenueDetails> createState() => _OwnerVenueDetailsState();
}

class _OwnerVenueDetailsState extends State<OwnerVenueDetails> {
  final formKey = GlobalKey<FormState>();

  final AppController appCon = Get.put(AppController());
  final OwnerController ownCon = Get.put(OwnerController());

  // Venue Controllers
  final venueNameCon   = TextEditingController();
  final contactCon     = TextEditingController();
  final hourlyRateCon  = TextEditingController();
  final addressCon     = TextEditingController();
  final descriptionCon = TextEditingController();

  int selectedPitchIndex = 0;
  dynamic currentVenueId;
  List<dynamic> deletedPitchIds = [];
  double venueLat = 0.0;
  double venueLong = 0.0;

  // Selected Amenities
  final Set<String> selectedAmenities = {'Parking', 'Changing'};

  // Pitches List
  List<PitchModel> pitches = [
    PitchModel(name: 'Pitch A - Main Turf'),
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await ownCon.fetchVenueAndPitchesByOwner();

    if (data != null && mounted) {
      final venueRes = data['venue'];
      final List<dynamic> groundsRes = data['grounds'];

      setState(() {
        currentVenueId = venueRes['id'];

        venueNameCon.text   = venueRes['name'] ?? '';
        contactCon.text     = venueRes['phone_number'] ?? '';
        hourlyRateCon.text  = venueRes['base_price']?.toString() ?? '';
        addressCon.text     = venueRes['address'] ?? '';
        descriptionCon.text = venueRes['description'] ?? '';
        venueLat            = venueRes['latitude'] ?? 0.0;
        venueLong           = venueRes['longitude'] ?? 0.0;

        // Set amenities
        final List<dynamic> savedAmenities = venueRes['amenities'] ?? [];
        for (var item in appCon.amenitiesList) {
          if (savedAmenities.contains(item.label)) {
            item.isSelected = true;
          }
        }

        // Re-assign pitches list completely
        if (groundsRes.isNotEmpty) {
          pitches = groundsRes.map<PitchModel>((g) {
            final double modifierVal = (g['price_modifier'] as num?)?.toDouble() ?? 0.0;
            return PitchModel(
              id: g['id'],
              name: g['ground_name'] ?? '',
              format: g['format'] ?? '5-A-Side',
              surface: g['ground_type'] ?? 'AstroTurf',
              modifier: modifierVal >= 0 ? '+$modifierVal' : '$modifierVal',
            );
          }).toList();
        }
      });
    }
  }

  @override
  void dispose() {
    venueNameCon.dispose();
    contactCon.dispose();
    hourlyRateCon.dispose();
    addressCon.dispose();
    descriptionCon.dispose();
    for (var pitch in pitches) {
      pitch.nameCon.dispose();
      pitch.modifierCon.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Obx(() =>
                  ownCon.isLoadingData.isTrue
                    ? SizedBox(
                      height: Get.height - 150.h,
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                    : Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          appbarWidget(),
                          SizedBox(height: 12.h),
                          formWidget(),
                          SizedBox(height: 24.h),
                          amenitiesWidget(),
                          SizedBox(height: 28.h),
                          courtsAndPitchesHeader(),
                          SizedBox(height: 16.h),
                          pitchListWidget(),
                          SizedBox(height: 16.h),
                          addPitchButton(),
                          SizedBox(height: 28.h),
                          saveButton(),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                )
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget appbarWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, color: subtitleTextColor),
        ),
        Text('Venue Details', style: boldStyle(primaryTextColor, 24.sp)),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget formWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complete your facility profile to start accepting bookings.',
          style: regularStyle(subtitleTextColor, 14.sp),
        ),
        SizedBox(height: 20.h),
        
        // Venue Name
        CustomTextFormField(
          headingText: "VENUE / FUTSAL NAME",
          controller: venueNameCon,
          hintText: 'X-Arena',
          headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
          hintStyle: regularStyle(Color(0xFF6B7280), 16.sp),
          autoValidateMode: .onUserInteraction,
          validator: (value) => validateIsEmpty(string: value!),
        ),
        SizedBox(height: 16.h),

        // Contact Phone
        CustomTextFormField(
          headingText: "CONTACT PHONE NUMBER",
          controller: contactCon,
          keyboardType: TextInputType.phone,
          hintText: '9801234567',
          // suffixIcon: Icon(Icons.check_circle, color: Colors.green, size: 18.sp),
          headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
          hintStyle: regularStyle(Color(0xFF6B7280), 16.sp),
          autoValidateMode: .onUserInteraction,
          validator: (value) {
            final emptyError = validateIsEmpty(string: value ?? '');
            if (emptyError != null) return emptyError;
            final numberError = validateIsNumbers(string: value ?? '');
            if (numberError != null) return numberError;
            final exactlengthError = validateExactLength(string: value!, length: 10);
            if (exactlengthError != null) return exactlengthError;
            return null;
          },
        ),
        SizedBox(height: 16.h),

        // Base Rate
        CustomTextFormField(
          headingText: "BASE HOURLY RATE (RS.)",
          controller: hourlyRateCon,
          keyboardType: TextInputType.number,
          hintText: '1500',
          headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
          hintStyle: regularStyle(Color(0xFF6B7280), 16.sp),
          autoValidateMode: .onUserInteraction,
          validator: (value) {
            final emptyError = validateIsEmpty(string: value ?? '');
            if (emptyError != null) return emptyError;
            final numberError = validateIsNumbers(string: value ?? '');
            if (numberError != null) return numberError;
            return null;
          },
        ),
        SizedBox(height: 16.h),

        // Address Field
        CustomTextFormField(
          headingText: "ADDRESS / LOCATION",
          controller: addressCon,
          hintText: 'Search neighborhood or street...',
          prefixIcon: Icon(Icons.location_on_outlined, color: subtitleTextColor, size: 20.sp),
          headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
          hintStyle: regularStyle(Color(0xFF6B7280), 16.sp),
          autoValidateMode: .onUserInteraction,
          validator: (value) => validateIsEmpty(string: value!),
        ),        

        SizedBox(height: 12.h),

        // Map Preview Container
        Container(
          height: 140.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white10),
          ),
          child: CustomMapScreen(
            initialLat: venueLat,
            initialLng: venueLong,
            showCurrentLocation: true,
            showDirection: false,
            isSelectionMode: true,
            onLocationSelected: (LatLng location) {
              log("PARENT RECEIVED: ${location.latitude}, ${location.longitude}");
              setState(() {
                venueLat = location.latitude;
                venueLong = location.longitude;
              });
            },
          )
        ),
        SizedBox(height: 16.h),

        // Venue Description
        CustomTextFormField(
          headingText: "DESCRIPTION",
          controller: descriptionCon,
          hintText: 'Provide details about rules, facilities, opening hours, etc.',
          maxLines: 3, // Allows multiline input
          headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
          hintStyle: regularStyle(const Color(0xFF6B7280), 16.sp),
          autoValidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => validateIsEmpty(string: value!),
        ),
      ],
    );
  }

  Widget amenitiesWidget() {
    return Obx(() =>
      appCon.isLoadingAmenities.isTrue
        ? SizedBox.shrink()
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "AMENITIES",
              style: boldStyle(subtitleTextColor, 12.sp)
            ),
            SizedBox(height: 12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: appCon.amenitiesList.length,
              itemBuilder: (context, index) {
                final item = appCon.amenitiesList[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: () {
                    setState(() {
                      item.isSelected = !item.isSelected; // Toggle selection
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.isSelected ? const Color(0xFF132819) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: item.isSelected ? primaryColor : Colors.white24,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          getAmenityIcon(item.iconName),
                          color: item.isSelected ? const Color(0xFF00FF66) : subtitleTextColor,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          item.label,
                          style: regularStyle(item.isSelected ? Colors.white : subtitleTextColor, 13.sp),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
    );
  }

  Widget courtsAndPitchesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Courts & Pitches',
                style: boldStyle(primaryTextColor, 28.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                'Configure individual playing\nsurfaces.',
                style: regularStyle(subtitleTextColor, 16.sp).copyWith(height: 1.1),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3828),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '${pitches.length} Pitches Configured',
              style: regularStyle(primaryTextColor, 12.sp).copyWith(height: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget pitchListWidget() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pitches.length,
      separatorBuilder: (_, _) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final pitch = pitches[index];

        // Format validation fallback to ensure dropdown match
        final List<String> formatItems = ['5-A-Side', '7-A-Side', '11-A-Side'];
        final List<String> surfaceItems = ['AstroTurf', 'Natural Grass', 'Rubber Turf'];

        final currentFormat = formatItems.contains(pitch.selectedFormat)
            ? pitch.selectedFormat
            : formatItems.first;

        final currentSurface = surfaceItems.contains(pitch.selectedSurface)
            ? pitch.selectedSurface
            : surfaceItems.first;

        return InkWell(
          key: ValueKey(pitch.id ?? index), // Key ensures Flutter rebuilds list properly
          onTap: () => setState(() => selectedPitchIndex = index),
          child: Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: filledBgColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: index == selectedPitchIndex ? const Color(0xFF00FF66) : Colors.white10,
                width: index == selectedPitchIndex ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stadium_outlined, color: const Color(0xFF00FF66), size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Pitch #${index + 1}',
                          style: semiBoldStyle(subtitleTextColor, 20.sp),
                        ),
                      ],
                    ),
                    if (pitches.length > 1)
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            if (pitch.id != null) {
                              deletedPitchIds.add(pitch.id!); // Add ID to deletion list
                            }
                            pitches.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFFFB4AB)),
                      ),
                  ],
                ),
                SizedBox(height: 14.h),
                
                // Pitch Name
                CustomTextFormField(
                  headingText: "PITCH NAME",
                  controller: pitch.nameCon,
                  hintText: 'e.g. Pitch B',
                  headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
                  hintStyle: regularStyle(const Color(0xFF6B7280), 16.sp),
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => validateIsEmpty(string: value!),
                ),
                SizedBox(height: 12.h),
          
                // Format Dropdown
                dropdownField(
                  label: "FORMAT",
                  value: currentFormat,
                  items: formatItems,
                  onChanged: (val) => setState(() => pitch.selectedFormat = val!),
                ),
                SizedBox(height: 12.h),
          
                // Surface Type Dropdown
                dropdownField(
                  label: "SURFACE TYPE",
                  value: currentSurface,
                  items: surfaceItems,
                  onChanged: (val) => setState(() => pitch.selectedSurface = val!),
                ),
                SizedBox(height: 12.h),
          
                // Hourly Price Modifier
                CustomTextFormField(
                  headingText: "HOURLY PRICE MODIFIER",
                  controller: pitch.modifierCon,
                  keyboardType: TextInputType.number,
                  headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
                  hintStyle: regularStyle(const Color(0xFF6B7280), 16.sp),
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => validateIsEmpty(string: value!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: subtitleTextColor, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1B241E),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1B241E),
              icon: Icon(Icons.keyboard_arrow_down, color: subtitleTextColor),
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              items: items.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget addPitchButton() {
    return InkWell(
      onTap: () => setState(() => pitches.add(PitchModel())),
      child: Container(
        decoration: BoxDecoration(
          color: transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: primaryColor),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: primaryColor, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'ADD ANOTHER PITCH',
              style: regularStyle(primaryTextColor, 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget saveButton() {
    return InkWell(
      onTap: () async {
        if (formKey.currentState!.validate()) {
          List<String> selectedAmenityLabels = appCon.amenitiesList
            .where((item) => item.isSelected)
            .map((item) => item.label)
            .toList();

          var venueData = {
            "owner_id"    : read('userId'),
            "name"        : venueNameCon.text,
            "phone_number": contactCon.text,
            'base_price': double.tryParse(hourlyRateCon.text) ?? 0.0,
            "description": descriptionCon.text.trim(),
            'address': addressCon.text.trim(),
            'latitude': 27.7172, // Replace with actual lat from map state
            'longitude': 85.3240, // Replace with actual lng from map state
            'amenities': selectedAmenityLabels
          };

          List<Map<String, dynamic>> groundsList = pitches.map<Map<String, dynamic>>((pitch) {
            final rawModifier = pitch.modifierCon.text.replaceAll('+', '').trim();
            return {
              if (pitch.id != null) "id": pitch.id,
              "ground_name": pitch.nameCon.text.trim(),
              "format": pitch.selectedFormat,
              "ground_type": pitch.selectedSurface,
              "price_modifier": double.tryParse(rawModifier) ?? 0.0,
              "is_available": true,
            };
          }).toList();

          if (currentVenueId != null) {
            // --- UPDATE MODE ---
            await ownCon.updateVenueAndPitches(
              venueId: currentVenueId!,
              futsalVenues: venueData,
              futsalGround: groundsList,
              deletedPitchIds: deletedPitchIds,
            );
          } else {
            // --- CREATE MODE ---
            await ownCon.saveVenueAndPitches(
              futsalVenues: venueData,
              futsalGround: groundsList,
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: primaryTextColor,
          borderRadius: .circular(12.r),
        ),
        padding: .symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF000000), size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'SAVE VENUE & PITCHES',
              style: boldStyle(Color(0xFF000000), 16.sp)
            ),
          ],
        )
      ),
    );
  }

}