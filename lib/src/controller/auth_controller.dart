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

  // Future<bool> signIn(String email, String password) async {
  //   final response = await supabase.auth.signInWithPassword(
  //     email: email,
  //     password: password,
  //   );

  //   // if (response.error != null) {
  //   //   Get.snackbar('Login Error', response.error!.message);
  //   //   return false;
  //   // }

  //   return true;
  // }

  Future storeUser(String userId, Map<String, dynamic> userData) {
    try {
      return supabase.from('Users').insert({
        'id': userId,
        'full_name': userData['full_name'],
        'phone_number': userData['phone_number'],
        'role': userData['role'],
        'email': userData['email'],
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
      rethrow;
    }
  }

}