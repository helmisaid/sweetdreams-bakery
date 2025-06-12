import 'package:flutter/material.dart';
import 'auth_state.dart';
import 'auth_service.dart';
import '../screens/auth/login_screen.dart';

abstract class AuthRequiredState<T extends StatefulWidget> extends AuthStateBase<T> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _redirectIfNotLoggedIn();
  }

  Future<void> _redirectIfNotLoggedIn() async {
    if (!_authService.isLoggedIn && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> signOut() async {
    try {
      isLoading = true;
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (error) {
      handleError(error);
    } finally {
      isLoading = false;
    }
  }
}
