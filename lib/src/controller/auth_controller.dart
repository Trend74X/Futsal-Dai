import 'dart:developer';

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
        await storeUser(response.user!.id, userData);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      showToast(message: 'Login Error', isSuccess: false, isNotDissmiable: true);
      return false;
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

  Future storeUser(String userId, Map<String, dynamic> userData) async {
    try {
      final List<Map<String, dynamic>> response = await supabase.from('Users').insert({
        'id': userId,
        'full_name': userData['full_name'],
        'phone_number': userData['phone_number'],
        'role': userData['role'],
        'email': userData['email'],
      }).select();
      if (response.isNotEmpty)  log('Success! Inserted user: ${response.first}');
    } catch (e) {
      Get.snackbar('Error', e.toString());
      rethrow;
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