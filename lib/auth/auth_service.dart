// lib/auth/auth_service.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Get current user
  User? get currentUser => supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'display_name': displayName,
          },
        ),
      );

      await _ensureProfileExists();
    }
    return response;
  }

  // Sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

// get user rol
  Future<String> getUserRole() async {
    try {
      if (currentUser == null) {
        debugPrint('No current user. Returning role "user".');
        return 'user';
      }

      debugPrint('Attempting to get role for user: ${currentUser!.id}');
      var profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id_user', currentUser!.id)
          .maybeSingle();

      if (profile != null) {
        final role = profile['role'] ?? 'user';
        debugPrint('Success! Role from database is: "$role"');
        return role;
      }
      debugPrint('Profile not found in database. Attempting to create one...');
      await _ensureProfileExists();

      debugPrint('Re-fetching profile after creation attempt...');
      profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id_user', currentUser!.id)
          .maybeSingle();

      if (profile != null) {
        final role = profile['role'] ?? 'user';
        debugPrint('Success on second attempt! Role is: "$role"');
        return role;
      }
      debugPrint(
          'Could not retrieve profile even after creation. Returning default "user".');
      return 'user';
    } catch (e) {
      debugPrint('An error occurred in getUserRole: $e');
      return 'user'; 
    }
  }

  Future<void> _ensureProfileExists() async {
    try {
      if (currentUser == null) return;

      final profileCheck = await supabase
          .from('profiles')
          .select('id')
          .eq('id_user', currentUser!.id)
          .maybeSingle();

      if (profileCheck == null) {
        debugPrint('Creating profile row for user: ${currentUser!.id}');

        final role =
            currentUser!.email == 'admin@bakery.com' ? 'admin' : 'user';

        await supabase.from('profiles').insert({
          'id_user': currentUser!.id,
          'role': role,
          'email': currentUser!.email,
        });
        debugPrint(
            'Profile (for role) created successfully with role: "$role"');
      }
    } catch (e) {
      debugPrint('Error in _ensureProfileExists: $e');
    }
  }

  // Check if current user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  // Listen to auth state changes
  Stream<AuthState> get onAuthStateChange => supabase.auth.onAuthStateChange;
}
