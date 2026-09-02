import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:futsal_dai/src/helper/cache_manager.dart';
import 'package:futsal_dai/src/model/group_model.dart';
import 'package:futsal_dai/src/widgets/custom_toast.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Custom text controllers matching your existing code structure
  final formKey = GlobalKey<FormState>();
  final TextEditingController groupNameCon     = TextEditingController();
  final TextEditingController descriptionCon   = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Observables
  RxList<GroupModel> groupsList = <GroupModel>[].obs;
  var searchResults   = <Map<String, dynamic>>[].obs;
  var selectedMembers = <Map<String, dynamic>>[].obs;
  var isSearching     = false.obs;
  var isLoading       = false.obs;

  // attendance
  var attendanceDetail = <Map<String, dynamic>>[].obs;
  var matchAttendanceMap = <String, dynamic>{}.obs;

  //recruitment
  List recruitmentPost = [];

  // Search users function
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;

    try {
      final response = await supabase
          .from('users')
          .select('id, full_name, username, profile_pic')
          .eq('role', 'player')
          .or('full_name.ilike.%$query%,username.ilike.%$query%')
          .limit(8);

      searchResults.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      debugPrint('Error searching users: $e');
    } finally {
      isSearching.value = false;
    }
  }

  // Add user to selected list
  void selectUser(Map<String, dynamic> user) {
    if (!selectedMembers.any((member) => member['id'] == user['id'])) {
      selectedMembers.add(user);
      searchController.clear();
      searchResults.clear();
    }
  }

  // Remove user from selected list
  void removeUser(String userId) {
    selectedMembers.removeWhere((member) => member['id'] == userId);
  }

  // Create Group and Save Members to Supabase
  Future<void> createGroup() async {
    if (!formKey.currentState!.validate()) return;

    final groupName = groupNameCon.text.trim();
    final description = descriptionCon.text.trim();
    final currentUserId = read('userId');

    isLoading.value = true;

    try {
      // 1. Insert into `groups` table
      final groupData = await supabase
          .from('groups')
          .insert({
            'name': groupName,
            'description': description.isNotEmpty ? description : null,
            'created_by': currentUserId,
          })
          .select()
          .single();

      final String newGroupId = groupData['id'];

      // 2. Prepare members payload (Creator + Selected members)
      List<Map<String, dynamic>> membersToInsert = [
        {
          'group_id': newGroupId,
          'user_id': currentUserId,
          'status': 'active',
          'role': 'admin',
        }
      ];

      for (var member in selectedMembers) {
        if (member['id'] != currentUserId) {
          membersToInsert.add({
            'group_id': newGroupId,
            'user_id': member['id'],
            'status': 'pending',
            'role': 'member',
          });
        }
      }

      // 3. Bulk insert into `group_members` table
      await supabase.from('group_members').insert(membersToInsert);
      showToast(message: 'Group created successfully!', isSuccess: true);
      Get.back(); // Go back to previous screen
    } catch (e) {
      debugPrint('Error creating group: $e');
      showToast(message: 'Failed to create group: $e', isSuccess: false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyGroups() async {
    try {
      isLoading.value = true;
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      // 1. First, find all group IDs where the current user is involved (either as accepted or pending)
      final myMemberships = await supabase
          .from('group_members')
          .select('group_id')
          .eq('user_id', currentUserId);

      // Extract the group IDs into a list of strings
      final List<String> groupIds = (myMemberships as List)
          .map((item) => item['group_id'].toString())
          .toList();

      // If the user isn't in any groups, clear the list and exit
      if (groupIds.isEmpty) {
        groupsList.clear();
        return;
      }

      // 2. Fetch those specific groups and include ALL their members (pending & accepted)
      final response = await supabase
          .from('groups')
          .select('''
            id,
            name,
            description,
            image,
            created_by,
            group_members (
              user_id,
              status,
              role,
              users (
                id,
                full_name,
                username,
                profile_pic,
                role
              )
            )
          ''')
          .inFilter('id', groupIds) // Filters only groups you belong to
          .order('created_at', ascending: false);  // Sorting newest first

      groupsList.assignAll(
        (response as List).map((groupJson) => GroupModel.fromJson(groupJson)).toList(),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load groups: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMemberToGroup(String groupId, String userId) async {
    try {
      // Insert into group_members table with 'pending' status
      await supabase.from('group_members').insert({
        'group_id': groupId,
        'user_id': userId,
        'status': 'pending',
        'role': 'member',
      });

      showToast(message: 'Invitation sent successfully!', isSuccess: true);
    } catch (e) {
      showToast(message: 'Failed to add member: $e', isSuccess: false);
    }
  }

  Future<void> updateGroupInvite(String groupId, String userId, String status) async {
    try {

      if (status == 'active') {
        await supabase
            .from('group_members')
            .update({'status': status})
            .eq('group_id', groupId)
            .eq('user_id', userId);
        showToast(message: 'Invitation updated successfully!', isSuccess: true);
      } else if (status == 'remove') {
        await supabase
            .from('group_members')
            .delete()
            .eq('group_id', groupId)
            .eq('user_id', userId);
        showToast(message: 'Group left successfully!', isSuccess: true);
      }

    } catch (e) {
      showToast(message: 'Failed to updated member: $e', isSuccess: false);
    }
  }

  Future<void> getGroupData(String groupId) async {
    isLoading.value = true;
    try {
      final response = await supabase
        .from('groups')
        .select('''
          id,
          name,
          description,
          image,
          created_by,
          group_members (
            user_id,
            status,
            role,
            users (
              id,
              full_name,
              username,
              profile_pic,
              role
            )
          )
        ''')
        .eq('id', groupId);

      // Convert the response to a list of mutable maps
      List<Map<String, dynamic>> groupsList = List<Map<String, dynamic>>.from(response);

      // Sort the nested group_members alphabetically by the user's full_name
      for (var group in groupsList) {
        if (group['group_members'] != null) {
          (group['group_members'] as List).sort((a, b) {
            final nameA = a['users']?['full_name'] ?? '';
            final nameB = b['users']?['full_name'] ?? '';
            return nameA.toString().compareTo(nameB.toString());
          });
        }
      }

      // Assign to your observable list
      attendanceDetail.assignAll(groupsList);
    } catch (e) {
      log('Error fetching favorite venues list: $e');
      showToast(message: 'Could not load favorites.', isSuccess: false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMatchAttendanceData(String groupId, String bookingId) async {
    isLoading.value = true;
    try {
      // 1. Fetch group data and members
      final groupResponse = await supabase
          .from('groups')
          .select('''
            id,
            name,
            description,
            image,
            created_by,
            group_members (
              user_id,
              status,
              role,
              users (
                id,
                full_name,
                username,
                profile_pic,
                role
              )
            )
          ''')
          .eq('id', groupId)
          .eq('group_members.status', 'active');

      List<Map<String, dynamic>> groupsList = List<Map<String, dynamic>>.from(groupResponse);

      // Sort nested members alphabetically
      for (var group in groupsList) {
        if (group['group_members'] != null) {
          (group['group_members'] as List).sort((a, b) {
            final nameA = a['users']?['full_name'] ?? '';
            final nameB = b['users']?['full_name'] ?? '';
            return nameA.toString().compareTo(nameB.toString());
          });
        }
      }
      attendanceDetail.assignAll(groupsList);

      // 2. Fetch match attendance JSON map for this booking
      final attendanceResponse = await supabase
          .from('match_attendance')
          .select('attendance_data')
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (attendanceResponse != null && attendanceResponse['attendance_data'] != null) {
        matchAttendanceMap.assignAll(Map<String, dynamic>.from(attendanceResponse['attendance_data']));
      } else {
        matchAttendanceMap.clear();
      }

    } catch (e) {
      log('Error fetching match attendance data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Function to update user's choice ('IN' or 'OUT')
  Future<void> updateAttendance(String bookingId, String status) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Update local state map immediately for responsive UI
      matchAttendanceMap[userId] = status;
      matchAttendanceMap.refresh();

      // Send update to Supabase JSON column using jsonb_set
      await supabase.rpc('update_user_attendance', params: {
        'p_booking_id': bookingId,
        'p_user_id': userId,
        'p_status': status,
      });
      
    } catch (e) {
      log('Error updating attendance: $e');
      Get.snackbar('Error', 'Failed to update attendance status', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // recruitment
  // Inside GroupController
  Future<void> postToMercenaryBoard({
    required String bookingId,
    required String groupId,
    required int slotsNeeded,
    required String notes, // Can keep or remove parameter
  }) async {
    try {
      final userId = read('userId'); 

      await Supabase.instance.client
        .from('match_recruitment_posts')
        .insert({
          'match_id': bookingId,
          'group_id': groupId,
          'creator_id': userId,
          'slots_needed': slotsNeeded,
          'status': 'open',
        });

      Get.snackbar(
        'Success',
        'Successfully posted to Mercenary Board!',
        colorText: Colors.white,
        backgroundColor: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to post: $e',
        colorText: Colors.white,
        backgroundColor: Colors.red.shade800,
      );
    }
  }

  void fetchRecruitmentPosts() async {
    try {
      final String todayDate = DateTime.now().toIso8601String().split('T')[0];
      final response = await Supabase.instance.client
          .from('v_mercenary_posts')
          .select()
          .eq('status', 'open')
          .gte('booking_date', todayDate)
          .order('booking_date', ascending: true)
          .order('start_time', ascending: true);

      recruitmentPost = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load mercenary board: $e');
    }
  }

  Future<void> requestToJoinMatch(String postId) async {
    try {
      // Get the current logged-in player's ID (adjust based on how you store user session)
      final playerId = read('userId'); // or Supabase.instance.client.auth.currentUser?.id;

      if (playerId == null) {
        Get.snackbar('Error', 'You must be logged in to join a match.');
        return;
      }

      // Insert the join request into the match_requests table
      await Supabase.instance.client.from('match_requests').insert({
        'post_id': postId,
        'player_id': playerId,
        'status': 'pending', // Default status when applying
      });

      Get.snackbar(
        'Success',
        'Request sent to the host!',
        colorText: Colors.white,
        backgroundColor: Colors.green.shade800,
      );
    } catch (e) {
      // Catch unique constraint violations if the user already applied to this post
      if (e.toString().contains('duplicate key value')) {
        Get.snackbar('Notice', 'You have already requested to join this match.');
      } else {
        Get.snackbar('Error', 'Failed to send request: $e');
      }
    }
  }


  @override
  void onClose() {
    groupNameCon.dispose();
    descriptionCon.dispose();
    searchController.dispose();
    super.onClose();
  }
}