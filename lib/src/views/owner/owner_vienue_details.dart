import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:get/get.dart';

// Model to handle dynamic pitches
class PitchModel {
  TextEditingController nameCon = TextEditingController();
  TextEditingController modifierCon = TextEditingController(text: '+0.00');
  String selectedFormat = '5-A-Side';
  String selectedSurface = 'AstroTurf';

  PitchModel({String? name}) {
    if (name != null) nameCon.text = name;
  }
}

class OwnerVenueDetails extends StatefulWidget {
  const OwnerVenueDetails({super.key});

  @override
  State<OwnerVenueDetails> createState() => _OwnerVenueDetailsState();
}

class _OwnerVenueDetailsState extends State<OwnerVenueDetails> {
  final formKey = GlobalKey<FormState>();

  // Venue Controllers
  final venueNameCon  = TextEditingController();
  final contactCon    = TextEditingController();
  final hourlyRateCon = TextEditingController();
  final addressCon    = TextEditingController();

  int selectedPitchIndex = 0;

  // Selected Amenities
  final Set<String> selectedAmenities = {'Parking', 'Changing'};

  final List<Map<String, dynamic>> amenitiesList = [
    {'name': 'Parking', 'icon': Icons.local_parking},
    {'name': 'Changing', 'icon': Icons.water_drop_outlined},
    {'name': 'Night Lights', 'icon': Icons.light_mode_outlined},
    {'name': 'Cafe', 'icon': Icons.local_cafe_outlined},
  ];

  // Pitches List
  List<PitchModel> pitches = [
    PitchModel(name: 'Pitch A - Main Turf'),
    PitchModel(),
  ];

  @override
  void dispose() {
    venueNameCon.dispose();
    contactCon.dispose();
    hourlyRateCon.dispose();
    addressCon.dispose();
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
                child: Form(
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
          hintText: 'e.g. Thunder Arena',
          headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
          hintStyle: regularStyle(Color(0xFF6B7280), 16.sp),
        ),
        SizedBox(height: 16.h),

        // Contact Phone
        CustomTextFormField(
          headingText: "CONTACT PHONE NUMBER",
          controller: contactCon,
          keyboardType: TextInputType.phone,
          hintText: '+977 9801234567',
          suffixIcon: Icon(Icons.check_circle, color: Colors.green, size: 18.sp),
          headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
          hintStyle: regularStyle(Color(0xFF6B7280), 16.sp),
        ),
        SizedBox(height: 16.h),

        // Base Rate
        CustomTextFormField(
          headingText: "BASE HOURLY RATE (RS.)",
          controller: hourlyRateCon,
          keyboardType: TextInputType.number,
          hintText: '2500',
          headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
          hintStyle: regularStyle(Color(0xFF6B7280), 16.sp),
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
          child: Center(
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: const Color(0xFF00FF66),
              child: Icon(Icons.location_on, color: Colors.black, size: 22.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget amenitiesWidget() {
    return Column(
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
          itemCount: amenitiesList.length,
          itemBuilder: (context, index) {
            final item = amenitiesList[index];
            final isSelected = selectedAmenities.contains(item['name']);
            return InkWell(
              borderRadius: BorderRadius.circular(8.r),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedAmenities.remove(item['name']);
                  } else {
                    selectedAmenities.add(item['name']);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF132819) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.white24,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'], color: isSelected ? const Color(0xFF00FF66) : subtitleTextColor, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      item['name'],
                      style: regularStyle(isSelected ? Colors.white : subtitleTextColor, 13.sp)
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
            padding: .symmetric(horizontal: 8.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Color(0xFF2D3828),
              borderRadius: .circular(16.r),
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
        return InkWell(
          onTap: () => setState(() => selectedPitchIndex = index),
          child: Container(
            padding: .all(16.sp),
            decoration: BoxDecoration(
              color: filledBgColor,
              borderRadius: .circular(12.r),
              border: .all(
                color: index == selectedPitchIndex ? const Color(0xFF00FF66) : Colors.white10,
                width: index == selectedPitchIndex ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
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
                        padding: .zero,
                        onPressed: () {
                          setState(() {
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
                  hintStyle: regularStyle(Color(0xFF6B7280), 16.sp),
                ),
                SizedBox(height: 12.h),
          
                // Format Dropdown
                dropdownField(
                  label: "FORMAT",
                  value: pitch.selectedFormat,
                  items: ['5-A-Side', '7-A-Side', '11-A-Side'],
                  onChanged: (val) => setState(() => pitch.selectedFormat = val!),
                ),
                SizedBox(height: 12.h),
          
                // Surface Type Dropdown
                dropdownField(
                  label: "SURFACE TYPE",
                  value: pitch.selectedSurface,
                  items: ['AstroTurf', 'Natural Grass', 'Rubber Turf'],
                  onChanged: (val) => setState(() => pitch.selectedSurface = val!),
                ),
                SizedBox(height: 12.h),
          
                // Hourly Price Modifier
                CustomTextFormField(
                  headingText: "HOURLY PRICE MODIFIER",
                  controller: pitch.modifierCon,
                  keyboardType: TextInputType.number,
                  headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
                  hintStyle: regularStyle(Color(0xFF6B7280), 16.sp),
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
          borderRadius: .circular(12.r),
          border: .all(
            color: primaryColor
          )
        ),
        padding: .symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            Icon(Icons.add_circle_outline, color: primaryColor, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'ADD ANOTHER PITCH',
              style: regularStyle(primaryTextColor, 16.sp)
            )
          ],
        )
      ),
    );
  }

  Widget saveButton() {
    return InkWell(
      onTap: () {
        if (formKey.currentState!.validate()) {
          // Perform submit action
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