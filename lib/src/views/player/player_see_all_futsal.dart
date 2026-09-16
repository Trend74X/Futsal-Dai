
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/player_controller.dart';
import 'package:futsal_dai/src/helper/constant.dart';
import 'package:futsal_dai/src/helper/share_url.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/views/player/futsal_detail.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/custom_map.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';

class PlayerSeeAllFutsal extends StatefulWidget {
  const PlayerSeeAllFutsal({super.key});

  @override
  State<PlayerSeeAllFutsal> createState() => _PlayerSeeAllFutsalState();
}

class _PlayerSeeAllFutsalState extends State<PlayerSeeAllFutsal> {
  final PlayerController _con              = Get.put(PlayerController());
  final searchCon                          = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _con.loadAllVenues();

    // Listen to scroll position for pagination trigger with safety guards
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          _scrollController.position.maxScrollExtent > 0 && // Prevent trigger if content fits on screen
          !_con.isLoadingMore.value &&
          _con.hasMoreVenues) {
        
        _con.loadAllVenues(
          isMore: true,
          searchQuery: searchCon.text,
          selectedAmenities: getSelectedAmenities(), 
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(title: 'All Futsals'),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.h),
              child: SingleChildScrollView(
                controller: _scrollController, // Attach controller here
                child: Obx(() => _con.isLoadingAllVenues.isTrue
                    ? SizedBox(
                        height: Get.height * 0.6,
                        child: Center(
                            child: CircularProgressIndicator(color: primaryColor)),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          searchBarField(),
                          SizedBox(height: 16.h),
                          amenitiesWidget(),
                          SizedBox(height: 24.h),
                          if (_con.allVenues.isEmpty)
                            SizedBox(
                              height: Get.width,
                              child: Center(
                                child: Text(
                                  'No venues to show right now.',
                                  style: semiBoldStyle(Colors.grey, 14.sp),
                                ),
                              ),
                            ),
                          savedCourtsWidget(),
                          // Loading indicator at the bottom when fetching more
                          if (_con.isLoadingMore.isTrue)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: primaryColor),
                              ),
                            ),
                          SizedBox(height: 24.h),
                        ],
                      )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget searchBarField() {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            headingText: "",
            headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.text,
            controller: searchCon,
            maxLines: 1,
            hintText: 'Search By Name',
            hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
            onChanged: (value) => setState(() { }),
            onFieldSubmitted: (value) {
              if(value != '') {
                _con.loadAllVenues(
                  searchQuery: value,
                  selectedAmenities: getSelectedAmenities(),
                );
              }
            },
            prefixIcon: Icon(Icons.search, color: disableButton),
            suffixIcon: IconButton(
              onPressed: () {
                searchCon.clear();
                _con.loadAllVenues(
                  searchQuery: '',
                  selectedAmenities: getSelectedAmenities(),
                );
                setState(() { });
              }, 
              icon: Visibility(
                visible: searchCon.text != '',
                child: Icon(Icons.close, color: disableButton)
              )
            ),
            height: 56.h,
          ),
        ),
        SizedBox(width: 8.w),
        InkWell(
          onTap: () {
            if (_con.allVenues.isEmpty) return;
            Get.to(() => CustomMapScreen(
              initialLat: _con.allVenues.first.latitude,
              initialLng: _con.allVenues.first.longitude,
              showCurrentLocation: true,
              showDirection: true,
              isSelectionMode: false,
              isFullScreenView: true,
              enableSearch: true,
              searchMode: MapSearchMode.futsalOnly,
              venues: _con.allVenues.map((venue) => MapVenueItem(
                id: venue.id,
                name: venue.name,
                address: venue.address,
                lat: venue.latitude,
                lng: venue.longitude,
                originalData: venue, // Passes your full model straight to FutsalDetail
              )).toList(),
              onSearchVenues: (query) async {
                await _con.loadAllVenues(
                  searchQuery: query,
                  selectedAmenities: getSelectedAmenities(),
                );
                return _con.allVenues.map((venue) => MapVenueItem(
                  id: venue.id,
                  name: venue.name,
                  address: venue.address,
                  lat: venue.latitude,
                  lng: venue.longitude,
                  originalData: venue,
                )).toList();
              },
            ));
          },
          child: Container(
            height: 48.h,
            width: 48.w,
            decoration: BoxDecoration(
              border: .all(color: black2),
              borderRadius: .circular(8.r)
            ),
            child: Icon(Icons.map_outlined, color: primaryColor)
          ),
        )
      ],
    );
  }

  Widget amenitiesWidget() {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        itemCount: amenities.length,
        shrinkWrap: true,
        scrollDirection: .horizontal,
        separatorBuilder: (context, index) => SizedBox(width: 8.sp), 
        itemBuilder: (context, index) {
          var data = amenities[index];
          return InkWell(
            onTap: () => setState(() {
              data['isSelected'] = !data['isSelected'];
              _con.loadAllVenues(
                searchQuery: searchCon.text,
                selectedAmenities: getSelectedAmenities(),
              );
            }),
            child: Container(
              height: 34.h,
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              decoration: BoxDecoration(
                color: data['isSelected'] ? primaryColor : const Color(0xFF222D1E),
                borderRadius: BorderRadius.circular(20.r),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Icon(
                    data['icon'],
                    color: data['isSelected'] ? black : white,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    data['label'],
                    style: TextStyle(
                      color: data['isSelected'] ? black : white,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        }, 
      ),
    );
  }


  Widget savedCourtsWidget() {
    return ListView.separated(
      itemCount: _con.allVenues.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => SizedBox(height: 16.h), 
      itemBuilder: (context, index) {
        var data = _con.allVenues[index];
        return futsalCards(context, data, index);
      }, 
    );
  }

  Widget futsalCards(BuildContext context, dynamic data, int index) {
    return InkWell(
      onTap: () => Get.to(() => FutsalDetail(data: data)),
      child: Container(
        decoration: BoxDecoration(
          color: filledBlueColor.withValues(alpha: 0.9),
          borderRadius: .circular(24.r)
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: .only(
                topLeft: .circular(24.r),
                topRight: .circular(24.r)
              ),
              child: Image.asset(
                'assets/images/court.png', 
                height: 164.h,
                width: double.infinity,
                fit: .cover,
              ),
            ),
            Padding(
              padding: .symmetric(vertical: 16.h, horizontal: 16.w),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      Expanded(
                        child: Text(
                          data.name,
                          style: boldStyle(whiteTextColor, 24.sp).copyWith(height: 1.0),
                        ),
                      ),
                      // Text(
                      //   "Rs. ${data.basePrice.toInt()}",
                      //   style: boldStyle(primaryTextColor, 14.sp).copyWith(height: 1.0),
                      // )
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: whiteTextColor, size: 15.sp),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          data.address,
                          style: regularStyle(whiteTextColor, 14.sp).copyWith(height: 1.1),
                          maxLines: 2,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomUsualButton(
                          text: 'Book Now', 
                          height: 40.h,
                          bgColor: primaryTextColor,
                          onPressed: () {}
                          // Get.bottomSheet(
                          //   PlayerBookingConfirm(),
                          //   isScrollControlled: true,
                          //   ignoreSafeArea: false,
                          // ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      InkWell(
                        onTap: () => shareContent(context),
                        child: Container(
                          height: 36.h,
                          width: 48.w,
                          decoration: BoxDecoration(
                            color: Color(0xFF3C4B35).withValues(alpha: 0.3),
                            borderRadius: .circular(12.r)
                          ),
                          child: Icon(Icons.share, color: whiteTextColor),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<String> getSelectedAmenities() {
    List<String> amenitiesList = amenities
      .where((amenity) => amenity['isSelected'] == true)
      .map((amenity) => amenity['label'] as String)
      .toList();
    return amenitiesList;
  }

}