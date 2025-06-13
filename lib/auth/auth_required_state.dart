import 'package:flutter/material.dart';
import 'auth_state.dart';
import 'auth_service.dart';
import '../screens/auth/login_screen.dart';
import './auth_gate.dart';

abstract class AuthRequiredState<T extends StatefulWidget>
    extends AuthStateBase<T> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> signOut() async {
    try {
      isLoading = true;
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      }
    } catch (error) {
      handleError(error);
    } finally {
      isLoading = false;
    }
  }
}
