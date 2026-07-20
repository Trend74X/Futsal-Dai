import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:futsal_dai/src/model/user_model.dart';
import 'package:futsal_dai/src/views/auth/log_in.dart';
import 'package:futsal_dai/src/views/owner/owner_bottomsheet.dart';
import 'package:futsal_dai/src/views/player/player_bottomsheet.dart';
import 'package:futsal_dai/src/widgets/custom_toast.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {

  final supabase = Supabase.instance.client;

  UserModel? profile;

  Future<bool> signUp(Map<String, dynamic> userData) async {
    try {
      final response = await supabase.auth.signUp(
        email: userData['email'],
        password: userData['password'],
      );
      if (response.user != null) {
        final String userId = response.user!.id;
        String? profileUrl;
        if (userData['profile_pic'] != null && userData['profile_pic'] is File) {
          profileUrl = await uploadProfileImage(userId, userData['profile_pic']);
        }

        await storeUser(userId, userData, profileUrl);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      showToast(message: 'Login Error', isSuccess: false, isNotDissmiable: true);
      return false;
    }
  }

  /// Helper method to upload WebP avatar to Supabase Storage
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Unique file path per user inside the 'avatars' storage bucket
      final String filePath = 'profile_$userId.webp';

      // Upload to bucket 'avatars'
      await supabase.storage.from('profile_pic').upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(
          contentType: 'image/webp',
          cacheControl: '3600',
          upsert: true, // Overwrites if the file already exists
        ),
      );

      // Retrieve and return the public CDN URL
      final String publicUrl = supabase.storage.from('profile_pic').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      log('Image Upload Failed: $e');
      return null; // Return null if upload fails so account creation still completes
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        getUserById(response.user!.id);
      } else {
        showToast(message: 'Login failed: Session is null', isSuccess: false, isNotDissmiable: false);
        log('Login failed: Session is null');
      }
    } on AuthException catch (error) {
      showToast(message: error.message, isSuccess: false, isNotDissmiable: false);
      log('Login failed (AuthException): ${error.message}');
    } catch (error) {
      log('Login failed (Unexpected Error): $error');
    }
  }

  Future<void> signOutUser(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      if (!context.mounted) return;
      Get.offAll(() => LogInPage());
    } on AuthException catch (error) {
      if (!context.mounted) return;
      showToast(message: error.message, isSuccess: false);
    } catch (error) {
      if (!context.mounted) return;
      showToast(message: 'An unexpected error occurred while logging out.', isSuccess: false);
    }
  }

  Future storeUser(String userId, Map<String, dynamic> userData, profileUrl) async {
    try {
      final List<Map<String, dynamic>> response = await supabase.from('Users').insert({
        'id': userId,
        'full_name': userData['full_name'],
        'phone_number': userData['phone_number'],
        'role': userData['role'],
        'email': userData['email'],
        'profile_pic': profileUrl
      }).select();
      if (response.isNotEmpty)  log('Success! Inserted user: ${response.first}');
    } catch (e) {
      Get.snackbar('Error', e.toString());
      rethrow;
    }
  }

  Future<bool> updateUser(Map<String, dynamic> data) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "User not authenticated");
        return false;
      }

      String? avatarUrl;

      // 1. Upload/Overwrite profile picture if selected
      if (data['profile_pic'] != null && data['profile_pic'] is File) {
        File imageFile = data['profile_pic'];
        final filePath = 'profile_${user.id}.webp';

        // Upload using upsert to overwrite any old image
        await supabase.storage.from('profile_pic').upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(
            contentType: 'image/webp',
            cacheControl: '3600',
            upsert: true, // Overwrites existing profile picture
          ),
        );

        // Get updated Public URL
        avatarUrl = supabase.storage.from('profile_pic').getPublicUrl(filePath);
      }

      // 2. Prepare payload for the database
      final Map<String, dynamic> updatePayload = {
        "full_name": data["full_name"],
        "phone_number": data["phone_number"],
      };

      // Only add location coordinates if they are not null
      if (data["longitude"] != null) {
        updatePayload["longitude"] = data["longitude"];
      }
      if (data["latitude"] != null) {
        updatePayload["latitude"] = data["latitude"];
      }

      // Only update avatar_url in DB if a new picture was uploaded
      if (avatarUrl != null) {
        updatePayload["profile_pic"] = avatarUrl;
      }

      // 3. Perform update in 'Users' table matching the current user ID
      final response = await supabase
          .from('Users')
          .update(updatePayload)
          .eq('id', user.id)
          .select();

      if (response.isNotEmpty) {
        log('User profile updated successfully: ${response.first}');
        await getUserById(user.id);
        return true;
      }

      return false;
    } catch (e) {
      log('Update User Error: $e');
      Get.snackbar("Error", "Failed to update profile: $e");
      return false;
    }
  }

  Future getUserById(String userId) async {
    try {
      final data = await supabase.from('Users').select().eq('id', userId).maybeSingle();
      if (data != null) {
        profile = UserModel.fromJson(data);
        if(profile!.role == 'player') {
          Get.offAll(() => PlayerBottomsheet());
        } else {
          Get.offAll(() => OwnerBottomsheet());
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

}