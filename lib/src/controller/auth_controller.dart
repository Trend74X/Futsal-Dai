import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:futsal_dai/src/helper/cache_manager.dart';
import 'package:futsal_dai/src/helper/image_helper.dart';
import 'package:futsal_dai/src/helper/log_helper.dart';
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

  RxBool isLoggingIn = false.obs;

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
        logSuccess();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      logError();
      showToast(message: 'Sign Up Error', isSuccess: false, isNotDissmiable: true);
      return false;
    }
  }

  /// Helper method to upload WebP avatar to Supabase Storage
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Unique file path per user & upload time, so the CDN/cache-buster
      // returns a fresh URL every time the image is replaced
      final String filePath = 'profile_${userId}_${_timestampSuffix()}.webp';

      // Upload to bucket 'profile_pic'
      await supabase.storage.from('profile_pic').upload(
        filePath,
        imageFile,
        fileOptions: FileOptions(
          contentType: contentTypeForImage(imageFile),
          cacheControl: '3600',
          upsert: true, // Overwrites if the file already exists
        ),
      );

      // Retrieve and return the public CDN URL
      final String publicUrl = supabase.storage.from('profile_pic').getPublicUrl(filePath);
      logSuccess();
      return publicUrl;
    } catch (e) {
      logError();
      log('Image Upload Failed: $e');
      return null; // Return null if upload fails so account creation still completes
    }
  }

  /// Unique suffix used in storage filenames to bust CDN & app image caches
  String _timestampSuffix() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final y = now.year.toString();
    final mo = two(now.month);
    final d = two(now.day);
    final h = two(now.hour);
    final mi = two(now.minute);
    final s = two(now.second);
    return '$y$mo$d$h$mi$s'; // e.g. 202609241054
  }

  /// Deletes the current profile picture object from storage so
  Future<void> _deleteOldProfileImage(String userId, String oldUrl) async {
    try {
      if (oldUrl.isEmpty) return;

      // Use Uri to safely parse the URL (ignores query params like ?t=123)
      final Uri uri = Uri.parse(oldUrl);
      final List<String> segments = uri.pathSegments;

      // Find the bucket name in the path to isolate the file name
      final int bucketIndex = segments.indexOf('profile_pic');
      if (bucketIndex == -1 || bucketIndex == segments.length - 1) {
        log('Delete skipped: Bucket name "profile_pic" not found in URL.');
        return;
      }

      // Extract the exact file path and decode it (in case of %20 spaces)
      final List<String> objectPathSegments = segments.sublist(bucketIndex + 1);
      final String objectPath = Uri.decodeComponent(objectPathSegments.join('/'));

      if (objectPath.isEmpty) return;

      // Ensure it belongs to the user
      if (!objectPath.startsWith('profile_$userId')) {
        log('Delete skipped: File "$objectPath" does not match user ID "$userId".');
        return;
      }

      // Execute deletion
      final List<FileObject> deletedFiles = await supabase.storage.from('profile_pic').remove([objectPath]);
      
      if (deletedFiles.isEmpty) {
        log('Warning: Delete requested, but Supabase returned an empty list. (Check RLS policies)');
      } else {
        log('updateUser: Successfully deleted old avatar $objectPath');
      }

    } catch (e) {
      logError();
      log('updateUser: Failed to delete old avatar: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoggingIn(true);
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        write('userId', response.user!.id);
        getUserById(response.user!.id);
        String? fcm = await NotificationHelper.getFcmToken() ?? "FCM";
        await supabase.from('users').update({'fcm': fcm}).eq('id', response.user!.id);
        logSuccess();
      } else {
        showToast(message: 'Login failed: Session is null', isSuccess: false, isNotDissmiable: false);
        log('Login failed: Session is null');
      }
    } on AuthException catch (error) {
      logError();
      showToast(message: error.message, isSuccess: false, isNotDissmiable: false);
      log('Login failed (AuthException): ${error.message}');
    } catch (error) {
      logError();
      log('Login failed (Unexpected Error): $error');
    } finally {
      isLoggingIn(false);
    }
  }

  Future<void> signOutUser(BuildContext context) async {
    try {
      final user = supabase.auth.currentUser;
      
      // 1. Clear FCM token from database and Firebase instance if user exists
      if (user != null) {
        try {
          // Clear FCM column in Supabase database
          await supabase
              .from('users')
              .update({'fcm': null})
              .eq('id', user.id);

          // Delete the local device FCM registration token
          await NotificationHelper.messaging.deleteToken();
          logSuccess();
        } catch (e) {
          logError();
          log('Error clearing FCM token during logout: $e');
        }
      }

      // 2. Sign out from Supabase auth session
      await supabase.auth.signOut();
      
      if (!context.mounted) return;
      Get.offAll(() => LogInPage());
      logSuccess();
    } on AuthException catch (error) {
      logError();
      if (!context.mounted) return;
      showToast(message: error.message, isSuccess: false);
    } catch (error) {
      logError();
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
      logSuccess();
    } on AuthException catch (error) {
      logError();
      if (!context.mounted) return;
      showToast(message: error.message, isSuccess: false);
    } catch (error) {
      logError();
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
        logSuccess();
      }
    } on AuthException catch (error) {
      logError();
      if (!context.mounted) return;
      showToast(message: error.message, isSuccess: false);
    } catch (error) {
      logError();
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
      logSuccess();
    } catch (e) {
      logError();
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
      // 1. Capture the old URL before doing anything else
      final String? oldAvatarUrl = profile?.profilePic; 

      // 2. Upload/Overwrite profile picture if selected
      final dynamic pic = data['profile_pic'];
      if (pic != null && pic is File) {
        File imageFile = pic;
        final filePath = 'profile_${user.id}_${_timestampSuffix()}.webp';

        await supabase.storage.from('profile_pic').upload(
          filePath,
          imageFile,
          fileOptions: FileOptions(
            contentType: contentTypeForImage(imageFile),
            cacheControl: '3600',
            upsert: true, 
          ),
        );

        avatarUrl = supabase.storage.from('profile_pic').getPublicUrl(filePath);
      } 

      // 3. Prepare payload for the database
      final Map<String, dynamic> updatePayload = {
        "full_name": data["full_name"],
        "phone_number": data["phone_number"],
      };

      if (data["longitude"] != null) updatePayload["longitude"] = data["longitude"];
      if (data["latitude"] != null) updatePayload["latitude"] = data["latitude"];
      if (data["address"] != null) updatePayload["address"] = data["address"];
      if (data["email"] != null) updatePayload["email"] = data["email"];
      
      if (avatarUrl != null) {
        updatePayload["profile_pic"] = avatarUrl;
      }

      String? fcm = await NotificationHelper.getFcmToken() ?? "FCM";
      updatePayload["fcm"] = fcm;

      // 4. Perform update in 'Users' table
      final response = await supabase
          .from('users')
          .update(updatePayload)
          .eq('id', user.id)
          .select();

      if (response.isNotEmpty) {
        log('User profile updated successfully.');
        
        // 5. DB updated successfully. NOW it is safe to delete the old image.
        if (avatarUrl != null && oldAvatarUrl != null && oldAvatarUrl != avatarUrl) {
          await _deleteOldProfileImage(user.id, oldAvatarUrl);
        }

        await getUserById(user.id); // Fetch fresh data
        logSuccess();
        return true;
      }

      return false;
    } catch (e) {
      logError();
      log('Update User Error: $e');
      showToast(message:"Failed to update profile: $e", isSuccess: false);
      return false;
    }
  }

  Future getUserById(String userId, {bool needRoute = true}) async {
    try {
      final data = await supabase.from('users').select().eq('id', userId).maybeSingle();
      if (data != null) {
        profile = UserModel.fromJson(data);
        if(needRoute == true) {
          if(profile!.role == 'player') {
            Get.offAll(() => PlayerBottomsheet());
          } else if(profile!.role == 'owner') {
            getVenueId();
          } else if(profile!.role == 'admin') {
            Get.offAll(() => OwnerBottomsheet());();
          }
        }
      }
      logSuccess();
    } catch (e) {
      logError();
      log(e.toString());
    }
  }

  Future getVenueId() async {
    try {
      final data = await supabase.from('futsal_venues').select().eq('owner_id', read('userId')).maybeSingle();
      if (data != null) {
        write('venueId', data['id']);
      } else {
        write('venueId', 0);
      }
      Get.offAll(() => OwnerBottomsheet());
      logSuccess();
    } catch (e) {
      logError();
      log(e.toString());
    }
  }

}