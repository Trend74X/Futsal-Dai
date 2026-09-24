import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/app_controller.dart';
import 'package:futsal_dai/src/controller/owner_controller.dart';
import 'package:futsal_dai/src/helper/cache_manager.dart';
import 'package:futsal_dai/src/helper/image_helper.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/validators.dart';
import 'package:futsal_dai/src/model/amenities_model.dart';
import 'package:futsal_dai/src/model/pitch_model.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/custom_map.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_toast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

  // Venue photos (slider gallery, up to 5)
  final ImagePicker picker = ImagePicker();
  List<String> galleryImageUrls = [];
  bool isCompressingVenueImage = false;

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

        // Set existing gallery images
        final List<dynamic> galleryRes = venueRes['gallery_image_urls'] ?? [];
        galleryImageUrls = galleryRes.map((e) => e.toString()).toList();

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
      appBar: appBarWidget(title: 'Venue Details'),
      extendBodyBehindAppBar: true,
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
                          SizedBox(height: 12.h),
                          venueImageWidget(),
                          SizedBox(height: 20.h),
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

  Widget venueImageWidget() {
    final int totalImages = galleryImageUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "VENUE PHOTOS (SLIDER)",
              style: boldStyle(subtitleTextColor, 12.sp),
            ),
            Text(
              '$totalImages/5',
              style: boldStyle(
                totalImages >= 5 ? const Color(0xFFFFB4AB) : subtitleTextColor,
                12.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'Add up to 5 photos. These will be shown in a slider on your venue page.',
          style: regularStyle(subtitleTextColor, 12.sp),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.0,
          ),
          itemCount: totalImages < 5 ? totalImages + 1 : totalImages,
          itemBuilder: (context, index) {
            // Add tile shown at the end while under the 5 image cap
            if (index == totalImages) {
              return InkWell(
                onTap: isCompressingVenueImage ? null : _showVenueImagePicker,
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B241E),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.5),
                      width: 1.5.w,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isCompressingVenueImage
                          ? SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 2.5.w,
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_a_photo, color: primaryColor, size: 22.sp),
                            ),
                      SizedBox(height: 8.h),
                      Text(
                        isCompressingVenueImage ? 'Processing...' : 'Add Photo',
                        style: boldStyle(whiteTextColor, 13.sp),
                      ),
                    ],
                  ),
                ),
              );
            }

            ImageProvider provider = NetworkImage(galleryImageUrls[index]);

            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B241E),
                      image: DecorationImage(image: provider, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Positioned(
                  top: 4.r,
                  right: 4.r,
                  child: GestureDetector(
                    onTap: () => _deleteVenueImage(index),
                    child: Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete_outline, color: Color(0xFFFFB4AB), size: 13.sp),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

Future<void> _deleteVenueImage(int index) async {
  final String url = galleryImageUrls[index];

  // Confirm before permanently deleting from storage
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF0E171D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text('Delete photo?', style: boldStyle(primaryTextColor, 16.sp)),
      content: Text(
        'This will permanently remove the photo from storage.',
        style: regularStyle(subtitleTextColor, 14.sp),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text('Cancel', style: regularStyle(subtitleTextColor, 14.sp)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text('Delete', style: boldStyle(const Color(0xFFFFB4AB), 14.sp)),
        ),
      ],
    ),
  );
  if (confirmed != true || !mounted) return;

  setState(() => galleryImageUrls.removeAt(index));

  // Delete only this selected image from storage, triggered by the user click
  await ownCon.deleteVenueImages([url]);
}

Future<void> _showVenueImagePicker() async {
  final int remainingSlots = 5 - galleryImageUrls.length;
  if (remainingSlots <= 0) {
    showToast(message: 'Maximum 5 photos allowed', isSuccess: false);
    return;
  }

  await showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0E171D),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Venue Photo',
                style: boldStyle(primaryTextColor, 18.sp),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () => _pickVenueImage(ImageSource.camera),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28.r,
                          backgroundColor: primaryColor.withValues(alpha: 0.15),
                          child: Icon(Icons.camera_alt, color: primaryColor, size: 28.r),
                        ),
                        SizedBox(height: 8.h),
                        Text('Camera', style: regularStyle(subtitleTextColor, 14.sp)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _pickVenueImage(ImageSource.gallery),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28.r,
                          backgroundColor: primaryColor.withValues(alpha: 0.15),
                          child: Icon(Icons.photo_library, color: primaryColor, size: 28.r),
                        ),
                        SizedBox(height: 8.h),
                        Text('Gallery', style: regularStyle(subtitleTextColor, 14.sp)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _pickVenueImage(ImageSource source) async {
  Get.back(); // Close the bottom sheet

  final int remainingSlots = 5 - galleryImageUrls.length;
  if (remainingSlots <= 0) {
    showToast(message: 'Maximum 5 photos allowed', isSuccess: false);
    return;
  }

  if (source == ImageSource.gallery) {
    await _pickVenueMultipleImages(maxCount: remainingSlots);
  } else {
    await _pickVenueSingleImage();
  }
}

Future<void> _pickVenueMultipleImages({required int maxCount}) async {
  final List<XFile> pickedFiles = await picker.pickMultiImage(
    imageQuality: 90,
    limit: maxCount, // respects the 5-photo cap
  );
  if (pickedFiles.isEmpty) return;

  await _processPickedVenueImages(pickedFiles);
}

Future<void> _pickVenueSingleImage() async {
  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 90,
  );
  if (pickedFile == null) return;

  await _processPickedVenueImages([pickedFile]);
}

Future<void> _processPickedVenueImages(List<XFile> pickedFiles) async {
  // Re-check remaining capacity against the live list
  final int remainingSlots = 5 - galleryImageUrls.length;
  final List<XFile> filesToAdd = pickedFiles.take(remainingSlots).toList();
  if (filesToAdd.isEmpty) {
    showToast(message: 'Maximum 5 photos allowed', isSuccess: false);
    return;
  }

  setState(() => isCompressingVenueImage = true);

  final List<File> converted = [];
  for (final file in filesToAdd) {
    try {
      converted.add(await compressToWebp(file.path, prefix: 'venue'));
    } catch (e) {
      log('Venue image WebP conversion failed, using original: $e');
      converted.add(File(file.path));
    }
  }

  if (!mounted) return;

  // Upload immediately so the picked photo shows up in the gallery right away
  final List<String> uploadedUrls = await ownCon.uploadVenueImages(converted);

  if (!mounted) return;

  setState(() {
    galleryImageUrls.addAll(uploadedUrls);
    isCompressingVenueImage = false;
  });
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
            onLocationSelected: (LatLng location) async {
              log("PARENT RECEIVED: ${location.latitude}, ${location.longitude}");
              setState(() {
                venueLat = location.latitude;
                venueLong = location.longitude;
                addressCon.text = 'Fetching address...';
              });

              addressCon.text = await appCon.getAddressFromLatLng(location.latitude, location.longitude);
            },
          )
        ),
        SizedBox(height: 12.h),
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

          // Gallery already uploaded when photos were picked; just persist it
          final List<String> finalGallery = List.of(galleryImageUrls);

          var venueData = {
            "owner_id"    : read('userId'),
            "name"        : venueNameCon.text,
            "phone_number": contactCon.text,
            'base_price': double.tryParse(hourlyRateCon.text) ?? 0.0,
            "description": descriptionCon.text.trim(),
            'address': addressCon.text.trim(),
            'latitude': venueLat,
            'longitude': venueLong,
            'amenities': selectedAmenityLabels,
            'main_image_url': finalGallery.isNotEmpty ? finalGallery.first : null,
            'gallery_image_urls': finalGallery,
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

          bool saved = false;
          if (currentVenueId != null) {
            // --- UPDATE MODE ---
            saved = await ownCon.updateVenueAndPitches(
              venueId: currentVenueId!,
              futsalVenues: venueData,
              futsalGround: groundsList,
              deletedPitchIds: deletedPitchIds,
            );
          } else {
            // --- CREATE MODE ---
            saved = await ownCon.saveVenueAndPitches(
              futsalVenues: venueData,
              futsalGround: groundsList,
            );
          }

          // Clean up storage for photos removed via the delete button
          // (already handled immediately on click, so nothing to do here)

          // Return to the previous page once saved successfully
          if (saved && mounted) {
            Get.back();
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