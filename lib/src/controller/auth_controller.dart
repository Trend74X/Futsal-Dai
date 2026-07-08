import 'dart:developer';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {

  final supabase = Supabase.instance.client;

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
      Get.snackbar('Login Error', e.toString());
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        log('Login succeeded!');
        log('User ID: ${response.user?.id}');
        return true;
      } else {
        log('Login failed: Session is null');
        return false;
      }
    } on AuthException catch (error) {
      log('Login failed (AuthException): ${error.message}');
      return false;
    } catch (error) {
      log('Login failed (Unexpected Error): $error');
      return false;
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

}