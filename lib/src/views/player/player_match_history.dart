import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:futsal_dai/src/controller/player_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/views/common/report_widget.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/display_image.dart';
import 'package:get/get.dart';

class PlayerMatchHistory extends StatefulWidget {
  const PlayerMatchHistory({super.key});

  @override
  State<PlayerMatchHistory> createState() => _PlayerMatchHistoryState();
}

class _PlayerMatchHistoryState extends State<PlayerMatchHistory> {
  final PlayerController _con = Get.find<PlayerController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _con.getPlayerHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(title: 'Match History'),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Obx(
                () => _con.isgettingHistory.isTrue
                    ? SizedBox(
                        height: Get.height * 0.8,
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      )
                    : _con.matchHistory.isEmpty
                        ? _emptyHistoryView()
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 12.h),
                                totalTilesCard(),
                                SizedBox(height: 20.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                                  child: Text(
                                    'RECENT MATCHES',
                                    style: boldStyle(subtitleTextColor, 12.sp),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                transactionHistory(),
                                SizedBox(height: 20.h),
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

  Widget _emptyHistoryView() {
    return SizedBox(
      height: Get.height * 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 54.sp, color: subtitleTextColor.withValues(alpha: 0.5)),
            SizedBox(height: 12.h),
            Text(
              'No matches played yet',
              style: semiBoldStyle(whiteTextColor, 16.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              'Joined and completed matches will appear here',
              style: regularStyle(subtitleTextColor, 13.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget totalTilesCard() {
    final totalCount = _con.matchHistory.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Subtle gradient fading into a neon green tint
        gradient: LinearGradient(
          colors: [
            filledBlueColor.withValues(alpha: 0.9),
            primaryColor.withValues(alpha: 0.08), 
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)), // Glowing border effect
      ),
      child: Stack(
        children: [
          // Background watermark icon for depth
          Positioned(
            right: -15.w,
            bottom: -15.h,
            child: Icon(
              Icons.sports_soccer,
              size: 100.sp,
              color: primaryColor.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart_rounded, color: primaryColor, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'PLAYER RECORD', 
                      style: boldStyle(primaryColor, 12.sp).copyWith(letterSpacing: 1.2)
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalCount.toString(),
                      style: semiBoldStyle(whiteTextColor, 48.sp).copyWith(height: 1.0),
                    ),
                    SizedBox(width: 10.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Text(
                        'Total Matches\nPlayed',
                        style: semiBoldStyle(subtitleTextColor, 13.sp).copyWith(height: 1.2),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, color: primaryColor, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Officially Recorded',
                        style: regularStyle(subtitleTextColor, 12.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionHistory() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _con.matchHistory.length,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        var data = _con.matchHistory[index];
        return listTileCard(data);
      },
    );
  }

  Widget listTileCard(dynamic data) {
    final List participants = data['participant_names'] ?? data['participants'] ?? [];
    final String createdBy  = data['created_by'] ?? '';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => showParticipants(context, participants: participants, createdBy: createdBy),
        child: Container(
          decoration: BoxDecoration(
            color: filledBlueColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          padding: EdgeInsets.all(14.sp),
          child: Row(
            children: [
              Container(
                height: 44.h,
                width: 44.w,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.all(10.sp),
                child: SvgPicture.asset(
                  'assets/icons/player.svg',
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['venue_name'] ?? 'Futsal Pitch',
                      style: semiBoldStyle(whiteTextColor, 15.sp).copyWith(height: 1.1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 12.sp, color: subtitleTextColor),
                        SizedBox(width: 4.w),
                        Text(
                          "${data['booking_date']} • ${data['start_time']}",
                          style: regularStyle(subtitleTextColor, 12.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.groups_outlined, size: 14.sp, color: primaryColor),
                    SizedBox(width: 4.w),
                    Text(
                      '${participants.length}',
                      style: boldStyle(primaryColor, 12.sp),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right_rounded, size: 16.sp, color: subtitleTextColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showParticipants(BuildContext context, {required List participants, required String createdBy}) {
    final Color darkOliveBg = const Color(0xFF131A13);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: darkOliveBg,
      barrierColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => participantsWidget(participants, createdBy),
    );
  }

  Widget participantsWidget(List participants, String createdBy) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.70,
          minHeight: Get.height * 0.20,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Match Squad',
                    style: semiBoldStyle(whiteTextColor, 17.sp),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${participants.length} Players',
                      style: boldStyle(primaryColor, 12.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              SizedBox(height: 8.h),
              Flexible(
                child: participants.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Center(
                          child: Text(
                            'No players recorded for this match',
                            style: regularStyle(subtitleTextColor, 14.sp),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: participants.length,
                        separatorBuilder: (context, index) => SizedBox(height: 6.h),
                        itemBuilder: (context, index) {
                          var     player = participants[index];
                          String  name   = player['name'] ?? 'Player';
                          String? picUrl = player['profile_pic'];
                          String? userId = player['id'];

                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryColor.withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: (picUrl != null && picUrl.isNotEmpty)
                                        ? DisplayNetworkImage(
                                            imageUrl: picUrl,
                                            boxFit: BoxFit.cover,
                                            height: 38.h,
                                            width: 38.w,
                                          )
                                        : Container(
                                            height: 38.h,
                                            width: 38.w,
                                            color: Colors.white10,
                                            child: Icon(
                                              Icons.person,
                                              size: 22.sp,
                                              color: Colors.white54,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: semiBoldStyle(whiteTextColor, 15.sp),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  height: 40.h,
                                  width: 40.w,
                                  decoration: BoxDecoration(
                                  color: black8.withValues(alpha: 0.5),
                                    shape: .circle
                                  ),
                                  child: IconButton(
                                    onPressed: () => showReportDialog(
                                      context, 
                                      targetType: 'player',
                                      targetId: userId
                                    ),
                                    icon: Icon(
                                      Icons.flag,
                                      color: white,
                                      size: 18.r,
                                    )
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}