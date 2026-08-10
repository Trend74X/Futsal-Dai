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
          .from('Users')
          .select('id, full_name, username, profile_pic')
          .or('full_name.ilike.%$query%,username.ilike.%$query%')
          .limit(5);

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

      // Fetch groups where the user is a member using the junction table relation
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
              Users (
                id,
                full_name,
                username,
                profile_pic,
                role
              )
            )
          ''');

      // groupsList.assignAll(List<Map<String, dynamic>>.from(response));
      groupsList.assignAll(
        (response as List).map((groupJson) => GroupModel.fromJson(groupJson)).toList(),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load groups: $e');
    } finally {
      isLoading.value = false;
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