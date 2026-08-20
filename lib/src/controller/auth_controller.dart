import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:futsal_dai/src/helper/cache_manager.dart';
import 'package:futsal_dai/src/helper/notification_helper.dart';
import 'package:futsal_dai/src/model/user_model.dart';
import 'package:futsal_dai/src/views/auth/log_in.dart';
import 'package:futsal_dai/src/views/auth/verify_password_page.dart';
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
      showToast(message: 'Sign Up Error', isSuccess: false, isNotDissmiable: true);
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
        write('userId', response.user!.id);
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

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      if (!context.mounted) return;
      Get.to(() => VerifyPasswordPage(email: email));
      showToast(message: 'Password reset link sent to your email!', isSuccess: true);
    } on AuthException catch (error) {
      if (!context.mounted) return;
      showToast(message: error.message, isSuccess: false);
    } catch (error) {
      if (!context.mounted) return;
      showToast(message: 'An unexpected error occurred while changing password.', isSuccess: false);
    }
  }
  
  Future<void> verifyAndResetPassword(BuildContext context, String email, String token, String newPass) async {
    try {
      final response = await supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      if (!context.mounted) return;
      if (response.session != null) {
        await supabase.auth.updateUser(
          UserAttributes(password: newPass),
        );
        if (!context.mounted) return;
        showToast(message: 'Password updated successfully!', isSuccess: true);
        Get.offAll(() => LogInPage());
      }
    } on AuthException catch (error) {
      if (!context.mounted) return;
      showToast(message: error.message, isSuccess: false);
    } catch (error) {
      if (!context.mounted) return;
      showToast(message: 'An unexpected error occurred while changing password.', isSuccess: false);
    }
  }

  Future storeUser(String userId, Map<String, dynamic> userData, profileUrl) async {
    try {
      String? fcm = await NotificationHelper.getFcmToken() ?? "FCM";
      final List<Map<String, dynamic>> response = await supabase.from('users').insert({
        'id': userId,
        'full_name': userData['full_name'],
        'phone_number': userData['phone_number'],
        'role': userData['role'],
        'email': userData['email'],
        'profile_pic': profileUrl,
        'username': userData['username'],
        'fcm': fcm
      }).select();
      if (response.isNotEmpty)  log('Success! Inserted user: ${response.first}');
    } catch (e) {
      showToast(message: e.toString(), isSuccess: false);
      rethrow;
    }
  }

  Future<bool> updateUser(Map<String, dynamic> data) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        showToast(message:"User not authenticated", isSuccess: false);
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

      // Only add address if they are not null
      if (data["address"] != null) {
        updatePayload["address"] = data["address"];
      }

      // Only add email if they are not null
      if (data["email"] != null) {
        updatePayload["email"] = data["email"];
      }

      // Only update avatar_url in DB if a new picture was uploaded
      if (avatarUrl != null) {
        updatePayload["profile_pic"] = avatarUrl;
      }

      String? fcm = await NotificationHelper.getFcmToken() ?? "FCM";
      updatePayload["fcm"] = fcm;

      // 3. Perform update in 'Users' table matching the current user ID
      final response = await supabase
          .from('users')
          .update(updatePayload)
          .eq('id', user.id)
          .select();

      if (response.isNotEmpty) {
        log('User profile updated successfully.');
        await getUserById(user.id);
        return true;
      }

      return false;
    } catch (e) {
      log('Update User Error: $e');
      showToast(message:"Failed to update profile: $e", isSuccess: false);
      return false;
    }
  }

  Future getUserById(String userId) async {
    try {
      final data = await supabase.from('users').select().eq('id', userId).maybeSingle();
      if (data != null) {
        profile = UserModel.fromJson(data);
        if(profile!.role == 'player') {
          Get.offAll(() => PlayerBottomsheet());
        } else {
          await getVenueId();
          Get.offAll(() => OwnerBottomsheet());
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future getVenueId() async {
    try {
      final data = await supabase.from('futsal_venues').select().eq('owner_id', read('userId')).maybeSingle();
      if (data != null) {
        write('venueId', data['id']);
      }
    } catch (e) {
      log(e.toString());
    }
  }

}