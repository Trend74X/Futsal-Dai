import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/constant.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:get/get.dart';

class PlayerTeamShuffler extends StatefulWidget {
  const PlayerTeamShuffler({super.key});

  @override
  State<PlayerTeamShuffler> createState() => _PlayerTeamShufflerState();
}

class _PlayerTeamShufflerState extends State<PlayerTeamShuffler> {

  List presentMembers = [];
  int selectedTeams = 2;
  bool membershuffled = false;

  // Holds the generated teams structure: { 0: [player1, player2], 1: [player3, player4] }
  Map<int, List<dynamic>> generatedTeams = {};

  @override
  void initState() {
    super.initState();
    getPresentMembers();
  }

  void getPresentMembers() {
    presentMembers.clear();
    for (var member in squadStatusList) {
      if (member['status'] == 'IN') {
        presentMembers.add(member);
      }
    }
    setState(() {});
  }

  // --- SHUFFLE LOGIC ---
  void shuffleTeams() {
    if (presentMembers.isEmpty) return;

    // 1. Create a copy and shuffle randomly
    List shuffledList = List.from(presentMembers)..shuffle();

    // 2. Initialize empty lists for each team
    Map<int, List<dynamic>> tempTeams = {};
    for (int i = 0; i < selectedTeams; i++) {
      tempTeams[i] = [];
    }

    // 3. Round-robin distribution of players into teams
    for (int i = 0; i < shuffledList.length; i++) {
      int teamIndex = i % selectedTeams;
      tempTeams[teamIndex]!.add(shuffledList[i]);
    }

    // 4. Update UI
    setState(() {
      generatedTeams = tempTeams;
      membershuffled = true;
    });
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appbarWidget(),
                    SizedBox(height: 12.h),
                    headerWidget(),
                    SizedBox(height: 12.h),
                    shuffleWidget(),
                    SizedBox(height: 16.h),
                    membershuffled == false
                        ? squadStatus()
                        : shuffledTeamsWidget(),
                  ],
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
        Text('Team Shuffler', style: boldStyle(primaryTextColor, 24.sp)),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget headerWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shuffle Strategy', style: boldStyle(whiteTextColor, 28.sp)),
        Text(
          '${presentMembers.length} PLAYERS CHECKED-IN • READY TO SPLIT',
          style: boldStyle(primaryColor, 12.sp),
        ),
      ],
    );
  }

  Widget shuffleWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Container(
            width: 320,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown Container
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: PopupMenuButton<int>(
                        initialValue: selectedTeams,
                        color: const Color(0xFF232E24),
                        elevation: 8,
                        constraints: BoxConstraints.tightFor(
                          width: constraints.maxWidth,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        position: PopupMenuPosition.under,
                        offset: const Offset(0, 8),
                        onSelected: (int value) {
                          setState(() {
                            selectedTeams = value;
                          });
                          // Re-shuffle if teams were already generated
                          if (membershuffled) {
                            shuffleTeams();
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [2, 3, 4].map((int value) {
                            return PopupMenuItem<int>(
                              value: value,
                              height: 44,
                              padding: EdgeInsets.zero,
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                    '$value Teams',
                                    style: const TextStyle(
                                      color: Color(0xFFE2F0D9),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF232E24),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '$selectedTeams Teams',
                                    style: const TextStyle(
                                      color: Color(0xFFE2F0D9),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF798A7A),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                InkWell(
                  onTap: () {
                    shuffleTeams();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding: EdgeInsets.all(12.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.casino_outlined, // Updated to dice icon
                          size: 18.sp,
                          color: const Color(0xFF107100),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          membershuffled ? 'RESHUFFLE TEAMS' : 'SHUFFLE TEAMS',
                          style: boldStyle(const Color(0xFF107100), 12.sp),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget squadStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Players Feed', style: regularStyle(whiteTextColor, 16.sp)),
        SizedBox(height: 8.h),
        ListView.separated(
          itemCount: presentMembers.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => SizedBox(height: 4.w),
          itemBuilder: (context, index) {
            var data = presentMembers[index];
            return Container(
              width: double.infinity,
              margin: EdgeInsets.all(4.sp),
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: filledBgColor,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  Container(
                    height: 48.h,
                    width: 48.w,
                    decoration: BoxDecoration(
                      color: lightFilledBgColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'],
                          style: regularStyle(whiteTextColor, 16.sp),
                        ),
                        Text(
                          "Matches Played: ${data['matches_played']}",
                          style: regularStyle(subtitleTextColor, 14.sp),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // --- DISPLAY SHUFFLED TEAMS RESULT ---
  Widget shuffledTeamsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shuffled Teams', style: regularStyle(whiteTextColor, 16.sp)),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  membershuffled = false;
                });
              },
              icon: Icon(Icons.refresh, size: 16.sp, color: primaryColor),
              label: Text('Reset', style: boldStyle(primaryColor, 14.sp)),
            )
          ],
        ),
        SizedBox(height: 8.h),
        ListView.separated(
          itemCount: generatedTeams.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            List teamPlayers = generatedTeams[index] ?? [];
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: filledBgColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Team ${index + 1}',
                        style: boldStyle(primaryColor, 20.sp),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: lightFilledBgColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${teamPlayers.length} Players',
                          style: boldStyle(whiteTextColor, 12.sp),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Team Members
                  ...teamPlayers.map((player) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: subtitleTextColor, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            player['name'],
                            style: regularStyle(whiteTextColor, 15.sp),
                          ),
                          const Spacer(),
                          Text(
                            '${player['matches_played']} MP',
                            style: regularStyle(subtitleTextColor, 12.sp),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

}