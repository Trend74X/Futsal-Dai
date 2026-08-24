import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/app_controller.dart';
import 'package:futsal_dai/src/controller/auth_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/validators.dart';
import 'package:futsal_dai/src/widgets/custom_map.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_toast.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final AppController appCon   = Get.put(AppController());
  final AuthController authCon = Get.find();

  final Geocoding geocoding    = Geocoding();
  final formKey                = GlobalKey<FormState>();

  final userNameCon = TextEditingController();
  final fullNameCon = TextEditingController();
  final phoneNoCon  = TextEditingController();
  final emailCon    = TextEditingController();
  final addressCon  = TextEditingController();

  // --- Profile Image Variables ---
  final ImagePicker picker = ImagePicker();
  File? selectedWebpImage;
  bool isCompressingImage = false;

  // --- Location Variables ---
  double? latitude;
  double? longitude;
  bool isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    final profile = authCon.profile;
    if (profile != null) {
      fullNameCon.text = profile.fullName;
      phoneNoCon.text  = profile.phoneNumber;
      emailCon.text    = profile.email;
      addressCon.text  = profile.address ?? '';
      userNameCon.text = profile.userName ?? '';
      
      // Convert String? to double? safely
      latitude  = profile.latitude;
      longitude = profile.longitude;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 64.h),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_ios_new, color: subtitleTextColor),
                  ),
                  Center(child: profileImageWidget()),
                  SizedBox(height: 24.h),
                  updateForm(),
                  SizedBox(height: 48.h),
                ]
              ),
            )
          )
        ),
      ),
    );
  }

  ClipRRect updateForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: lightFilledBgColor,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08), 
            width: 1.0,
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              CustomTextFormField(
                headingText: "User Name",
                headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                // autoValidateMode: AutovalidateMode.onUserInteraction,
                readOnly: true,
                controller: userNameCon,
                maxLines: 1,
                hintText: 'user_1234',
                hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
                // validator: (value) => validateIsEmpty(string: value!),
                onChanged: (value){
                  setState(() {});
                },
              ),
              SizedBox(height: 8.h),
              CustomTextFormField(
                headingText: "Full Name",
                headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                controller: fullNameCon,
                maxLines: 1,
                hintText: 'Cristiano Ronaldo',
                hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
                validator: (value) => validateIsEmpty(string: value!),
                onChanged: (value){
                  setState(() {});
                },
              ),
              SizedBox(height: 8.h),
              CustomTextFormField(
                headingText: "Phone Number",
                headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                controller: phoneNoCon,
                maxLines: 1,
                hintText: '9801234567',
                hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (value) => validateMinMaxLength(string: value!, minLegth: 10, maxLength: 11),
                onChanged: (value){
                  setState(() {});
                },
              ),
              SizedBox(height: 8.h),
              CustomTextFormField(
                headingText: "Email Address",
                headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                controller: emailCon,
                maxLines: 1,
                hintText: 'futsal_pro@example.com',
                hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
                readOnly: true,
                inputFormatters: [ LengthLimitingTextInputFormatter(35) ],
                validator: (value) => validateEmail(string: value!),
                onChanged: (value){
                  setState(() {});
                },
              ),
              SizedBox(height: 8.h),
              Container(
                height: 140.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white10),
                ),
                child: CustomMapScreen(
                  initialLat: latitude!,
                  initialLng: longitude!,
                  showCurrentLocation: true,
                  showDirection: false,
                  isSelectionMode: true,
                  returnAddressOnLocation: true,
                  onLocationSelected: (LatLng location) async {
                    log("PARENT RECEIVED: ${location.latitude}, ${location.longitude}");
                    latitude = location.latitude;
                    longitude = location.longitude;
                    addressCon.text = 'Fetching address...';
                    addressCon.text = await appCon.getAddressFromLatLng(location.latitude, location.longitude);
                    setState(() { });
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
              // CustomTextFormField(
              //   headingText: "Location Address",
              //   headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
              //   textInputAction: TextInputAction.done,
              //   keyboardType: TextInputType.streetAddress,
              //   controller: addressCon,
              //   maxLines: 1,
              //   hintText: 'Tap icon to fetch GPS location',
              //   hintStyle: TextStyle(fontSize: 14.sp, color: disableButton, fontWeight: FontWeight.normal),
              //   validator: (value) => validateIsEmpty(string: value!),
              //   suffixIcon: isFetchingLocation
              //       ? Padding(
              //           padding: EdgeInsets.all(12.r),
              //           child: SizedBox(
              //             width: 16.w,
              //             height: 16.h,
              //             child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2),
              //           ),
              //         )
              //       : IconButton(
              //           icon: Icon(Icons.my_location, color: primaryColor),
              //           onPressed: _getCurrentLocation,
              //         ),
              // ),
              
              if (latitude != null && longitude != null) ...[
                SizedBox(height: 4.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "GPS: ${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}",
                    style: TextStyle(color: primaryColor, fontSize: 12.sp),
                  ),
                ),
              ],
              SizedBox(height: 24.h),

              CustomUsualButton(
                text: 'Update Profile',
                fontSize: 16.sp,
                fontWeight: .bold,
                onPressed: () async {
                  final isValid = formKey.currentState!.validate();
                  if (!isValid) return;
                  var data = {
                    "full_name"   : fullNameCon.text.trim(),
                    "phone_number": phoneNoCon.text.trim(),
                    "email"       : emailCon.text.trim(),
                    "address"     : addressCon.text.trim(),
                    "longitude"   : longitude,
                    "latitude"    : latitude,
                    "profile_pic" : selectedWebpImage
                  };
                  bool profileUpdated = await authCon.updateUser(data);
                  if (profileUpdated) Get.back();
                },
                height: 56.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Avatar Picker Widget ---
  Widget profileImageWidget() {
    final String? remoteAvatarUrl = authCon.profile!.profilePic;

    // Resolve image provider: local file first, network URL second
    ImageProvider? imageProvider;
    if (selectedWebpImage != null) {
      imageProvider = FileImage(selectedWebpImage!);
    } else if (remoteAvatarUrl != null && remoteAvatarUrl.isNotEmpty) {
      imageProvider = NetworkImage(remoteAvatarUrl);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: isCompressingImage ? null : showImagePickerModal,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0E171D),
                  border: Border.all(
                    color: primaryColor,
                    width: 2.w,
                  ),
                  image: imageProvider != null
                      ? DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageProvider == null
                    ? Icon(
                        Icons.person,
                        size: 50.r,
                        color: subtitleTextColor,
                      )
                    : null,
              ),
              if (isCompressingImage)
                SizedBox(
                  width: 100.r,
                  height: 100.r,
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3.w,
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16.r,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Upload Profile Picture',
          style: TextStyle(
            fontSize: 12.sp,
            color: subtitleTextColor,
          ),
        ),
      ],
    );
  }

  Future<void> pickProfileImage(ImageSource source) async {
    Get.back(); // Close modal bottom sheet

    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    if (pickedFile == null) return;

    setState(() => isCompressingImage = true);

    try {
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = p.join(
        dir.absolute.path,
        "profile_${DateTime.now().millisecondsSinceEpoch}.webp",
      );

      // Compress and convert to WebP
      final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        format: CompressFormat.webp,
        quality: 80,
        minWidth: 500,  // Capped dimensions suitable for avatars
        minHeight: 500,
      );

      if (compressedXFile != null) {
        setState(() {
          selectedWebpImage = File(compressedXFile.path);
        });
      }
    } catch (e) {
      showToast(message: 'Could not process image: $e', isSuccess: false);
    } finally {
      setState(() => isCompressingImage = false);
    }
  }

  // --- Camera / Gallery Bottom Sheet ---
  void showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E171D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Profile Picture',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => pickProfileImage(ImageSource.camera),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 28.r,
                            backgroundColor: primaryColor.withValues(alpha: 0.15),
                            child: Icon(Icons.camera_alt, color: primaryColor, size: 28.r),
                          ),
                          SizedBox(height: 8.h),
                          Text('Camera', style: TextStyle(color: subtitleTextColor, fontSize: 14.sp)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => pickProfileImage(ImageSource.gallery),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 28.r,
                            backgroundColor: primaryColor.withValues(alpha: 0.15),
                            child: Icon(Icons.photo_library, color: primaryColor, size: 28.r),
                          ),
                          SizedBox(height: 8.h),
                          Text('Gallery', style: TextStyle(color: subtitleTextColor, fontSize: 14.sp)),
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

  // --- Fetch GPS Location and Reverse Geocode ---
  // Future<void> _getCurrentLocation() async {
  //   setState(() => isFetchingLocation = true);

  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       showToast(message: 'Location services are disabled on your phone.', isSuccess: false);
  //       setState(() => isFetchingLocation = false);
  //       return;
  //     }

  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         showToast(message: 'Location permissions are required.', isSuccess: false);
  //         setState(() => isFetchingLocation = false);
  //         return;
  //       }
  //     }

  //     if (permission == LocationPermission.deniedForever) {
  //       showToast(message: 'Please enable location permission in settings.', isSuccess: false);
  //       setState(() => isFetchingLocation = false);
  //       return;
  //     }

  //     Position position = await Geolocator.getCurrentPosition(
  //       locationSettings: const LocationSettings(
  //         accuracy: LocationAccuracy.high,
  //       ),
  //     );

  //     latitude = position.latitude;
  //     longitude = position.longitude;

  //     // Directly call package-level function
  //     List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(
  //       position.latitude,
  //       position.longitude,
  //     );

  //     if (placemarks.isNotEmpty) {
  //       Placemark place = placemarks[0];
  //       String formattedAddress = "${place.street}, ${place.subLocality}, ${place.locality}";
        
  //       setState(() {
  //         addressCon.text = formattedAddress;
  //       });
  //     }
  //   } catch (e) {
  //     showToast(message: 'Failed to retrieve location: $e', isSuccess: false);
  //   } finally {
  //     setState(() => isFetchingLocation = false);
  //   }
  // }

}