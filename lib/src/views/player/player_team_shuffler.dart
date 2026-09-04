import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/group_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/validators.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_toast.dart';
import 'package:get/get.dart';

class PlayerTeamShuffler extends StatefulWidget {
  final String bookingId, groupId;
  const PlayerTeamShuffler({super.key, required this.bookingId, required this.groupId});

  @override
  State<PlayerTeamShuffler> createState() => _PlayerTeamShufflerState();
}

class _PlayerTeamShufflerState extends State<PlayerTeamShuffler> {
  final controller = Get.put(GroupController());

  int selectedTeams = 2;
  bool membershuffled = false;

  // Local temporary list to handle manual guest players for the shuffle session only
  List<Map<String, dynamic>> manualPlayers = [];
  List confirmedPlayers = [];

  // Holds the generated teams structure: { 0: [player1, player2], 1: [player3, player4] }
  Map<int, List<dynamic>> generatedTeams = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.getMatchAttendanceData(widget.groupId, widget.bookingId);
      await loadConfirmedPlayers();
      setState(() {}); // Safe to call here after fetch completes
    });
  }

  Future<void> loadConfirmedPlayers() async {
    List players = await controller.fetchMatchJoinRequests(widget.bookingId); 
    confirmedPlayers = players.where((req) => req['status'] == 'accepted' || req['status'] == 'confirmed').toList();
    setState(() {});
  }

  // Getter to combine checked-in members, manual guest players, and confirmed mercenary players
  List get presentMembers {
    // 1. Group members checked-in as 'IN'
    final membersList = (controller.attendanceDetail.isNotEmpty && controller.attendanceDetail[0]['group_members'] != null)
        ? List.from(controller.attendanceDetail[0]['group_members'])
        : [];

    final dbInMembers = membersList.where((member) {
      final userId = member['user_id']?.toString();
      final status = controller.matchAttendanceMap[userId];
      return status == 'IN';
    }).toList();

    // 2. Format confirmed mercenary players to match the member structure
    final formattedConfirmedPlayers = confirmedPlayers.map((req) {
      var user = req['player'] ?? {};
      return {
        'is_mercenary': true,
        'role': 'Mercenary',
        'users': {
          'full_name': user['full_name'],
          'profile_pic': user['profile_pic'],
          'username': user['username'],
        }
      };
    }).toList();

    // 3. Combine database checked-in members, manual guest players, and confirmed mercenaries
    return [...dbInMembers, ...manualPlayers, ...formattedConfirmedPlayers];
  }

  // --- DIALOG FOR MANUAL GUEST PLAYER ---
  void _showAddManualPlayerDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    Get.defaultDialog(
      title: "Add Guest Player",
      titleStyle: boldStyle(whiteTextColor, 18.sp),
      titlePadding: .only(top: 28.h),
      backgroundColor: filledBgColor,
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          children: [
            CustomTextFormField(
              headingText: "",
              headingTextStyle: regularStyle(subtitleTextColor, 16.sp),
              textInputAction: .done,
              keyboardType: .text,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              controller: nameController,
              maxLines: 1,
              hintText: 'Enter player name',
              hintStyle: regularStyle(disableButton, 16.sp),
              validator: (value) => validateIsEmpty(string: value!),
              onChanged: (value) => setState(() {}),
              filled: true,
              filledColor: filledBlueColor,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel', style: regularStyle(subtitleTextColor, 14.sp)),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        // FIXED: Changed 'Users' to 'users' so it matches the reader structure
                        manualPlayers.add({
                          'is_manual': true,
                          'role': 'Guest',
                          'users': {
                            'full_name': name,
                            'profile_pic': null,
                          }
                        });
                        membershuffled = false; 
                      });
                      Get.back();
                    }
                  },
                  child: Text('Add', style: boldStyle(const Color(0xFF107100), 14.sp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- SHUFFLE LOGIC ---
  void shuffleTeams() {
    final currentPresent = presentMembers;
    if (currentPresent.isEmpty) return;

    if(currentPresent.length < selectedTeams) {
      showToast(message: 'Active members are not enough to shuffle.', isSuccess: false);
      return;
    }

    List shuffledList = List.from(currentPresent)..shuffle();

    Map<int, List<dynamic>> tempTeams = {};
    for (int i = 0; i < selectedTeams; i++) {
      tempTeams[i] = [];
    }

    for (int i = 0; i < shuffledList.length; i++) {
      int teamIndex = i % selectedTeams;
      tempTeams[teamIndex]!.add(shuffledList[i]);
    }

    setState(() {
      generatedTeams = tempTeams;
      membershuffled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(title: 'Team Shuffler'),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Obx(() {
                  if (controller.isLoading.isTrue) {
                    return SizedBox(
                      height: Get.height * 0.8,
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    );
                  }

                  final currentPresent = presentMembers;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      headerWidget(currentPresent.length),
                      SizedBox(height: 12.h),
                      shuffleWidget(),
                      SizedBox(height: 12.h),
                      membershuffled == false
                        ? squadStatus(currentPresent) // FIXED: Removed duplicate confirmedSquadWidget call since presentMembers combines them
                        : shuffledTeamsWidget(),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget headerWidget(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shuffle Strategy', style: boldStyle(whiteTextColor, 28.sp)),
        Text(
          '$count PLAYERS READY • READY TO SPLIT',
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
                SizedBox(height: 12.h),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    minimumSize: Size(double.infinity, 44.h),
                  ),
                  onPressed: () => _showAddManualPlayerDialog(context),
                  icon: Icon(Icons.person_add_alt_1_outlined, size: 16.sp, color: primaryColor),
                  label: Text(
                    'Add Guest Player',
                    style: regularStyle(primaryColor, 14.sp),
                  ),
                ),
                SizedBox(height: 12.h),
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
                          Icons.casino_outlined,
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

  Widget squadStatus(List currentPresent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Combined Squad Feed (${currentPresent.length})', style: regularStyle(whiteTextColor, 16.sp)),
        SizedBox(height: 8.h),
        currentPresent.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Text(
                    'No players available to shuffle yet.',
                    style: regularStyle(subtitleTextColor, 14.sp),
                  ),
                ),
              )
            : ListView.separated(
                itemCount: currentPresent.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(height: 4.w),
                itemBuilder: (context, index) {
                  var member = currentPresent[index];
                  var user = member['users'] ?? {};
                  bool isManual = member['is_manual'] == true;
                  bool isMercenary = member['is_mercenary'] == true;

                  String roleLabel = member['role'] ?? 'Member';
                  if (isMercenary) roleLabel = 'Mercenary';
                  if (isManual) roleLabel = 'Guest';

                  return Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(4.sp),
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: filledBgColor,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: lightFilledBgColor,
                          backgroundImage: user['profile_pic'] != null
                              ? NetworkImage(user['profile_pic'])
                              : null,
                          child: user['profile_pic'] == null
                              ? Icon(Icons.person, color: subtitleTextColor)
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['full_name'] ?? 'Unknown User',
                                style: regularStyle(whiteTextColor, 16.sp),
                              ),
                              Text(
                                "Role: $roleLabel",
                                style: regularStyle(subtitleTextColor, 14.sp),
                              ),
                            ],
                          ),
                        ),
                        if (isManual)
                          IconButton(
                            icon: Icon(Icons.close, color: const Color(0xFFFFB4AB), size: 18.sp),
                            onPressed: () {
                              setState(() {
                                manualPlayers.remove(member);
                              });
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

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
                  ...teamPlayers.map((member) {
                    var user = member['users'] ?? {};
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14.r,
                            backgroundColor: lightFilledBgColor,
                            backgroundImage: user['profile_pic'] != null
                                ? NetworkImage(user['profile_pic'])
                                : null,
                            child: user['profile_pic'] == null
                                ? Icon(Icons.person, size: 12.sp, color: subtitleTextColor)
                                : null,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              user['full_name'] ?? 'Unknown User',
                              style: regularStyle(whiteTextColor, 15.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            member['role'] ?? 'Member',
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