
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/player_controller.dart';
import 'package:futsal_dai/src/helper/share_url.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/views/player/futsal_detail.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final PlayerController _con = Get.put(PlayerController());

  @override
  void initState() {
    super.initState();
    _con.fetchFavoriteVenues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(title: 'FAVORITES'),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: Padding(
              padding: .symmetric(horizontal: 16.sp, vertical: 8.h),
              child: SingleChildScrollView(
                child: Obx(()=>
                  _con.isLoadingFavs.isTrue
                    ? Center(child: CircularProgressIndicator(color: primaryColor))
                    : Column(
                      crossAxisAlignment: .start,
                      children: [
                        SizedBox(height: 16.h),
                        titleAndCountsWidgets(),
                        SizedBox(height: 16.h),
                        if (_con.favoriteVenuesList.isEmpty) 
                          SizedBox(
                            height: Get.width,
                            child: Center(
                              child: Text(
                                'No venues favorites or saved right now.',
                                style: semiBoldStyle(Colors.grey, 14.sp),
                              )
                            ),
                          ),
                        savedCourtsWidget()
                      ],
                    ),
                )
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget titleAndCountsWidgets() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'YOUR COURTS',
          style: boldStyle(primaryTextColor, 12.sp),
        ),
        Row(
          mainAxisAlignment: .spaceBetween,
          crossAxisAlignment: .end,
          children: [
            Text(
              'Saved Venues',
              style: semiBoldStyle(whiteTextColor, 20.sp),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xff2D3828),
                borderRadius: .circular(4.r)
              ),
              padding: .symmetric(vertical: 4.h, horizontal: 8.w),
              child: Text(
                '${_con.favoriteVenuesList.length} Venues',
                style: boldStyle(whiteTextColor, 12.sp),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget savedCourtsWidget() {
    return ListView.separated(
      itemCount: _con.favoriteVenuesList.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => SizedBox(height: 16.h), 
      itemBuilder: (context, index) {
        var data = _con.favoriteVenuesList[index];
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: .only(
                    topLeft: .circular(24.r),
                    topRight: .circular(24.r)
                  ),
                  child: Image.asset(
                    'assets/images/court.png', 
                    height: 192.h,
                    width: double.infinity,
                    fit: .cover,
                  ),
                ),
                Positioned(
                  right: 8.w,
                  child: IconButton(
                    onPressed: () async {
                      bool success = await _con.toggleFavorite(data.id, false);
                      setState(() {
                        if(success) _con.favoriteVenuesList.removeAt(index);
                      });
                    },
                    icon: Icon(Icons.favorite, color: primaryColor)
                  )
                )
              ],
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
                          style: boldStyle(whiteTextColor, 28.sp).copyWith(height: 1.0),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            "Rs. ${data.basePrice.toInt()}",
                            style: boldStyle(primaryTextColor, 14.sp).copyWith(height: 1.0),
                          ),
                          Text(
                            '/ hour',
                            style: boldStyle(subtitleTextColor, 14.sp).copyWith(height: 1.0),
                          ),
                        ],
                      )
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
}