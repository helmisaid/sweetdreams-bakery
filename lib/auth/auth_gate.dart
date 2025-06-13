import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart'; // Untuk akses `supabase` client
import '../screens/admin/admin_dashboard.dart';
import '../screens/user/home_screen.dart';
import '../screens/auth/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data?.session != null) {
          return FutureBuilder<String>(
            future: _getUserRole(), 
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (roleSnapshot.data == 'admin') {
                return const AdminDashboard();
              }
              return const HomeScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }

  Future<String> _getUserRole() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return 'user';

      final profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id_user', user.id)
          .single();
      
      return profile['role'] ?? 'user';
    } catch (e) {
      return 'user';
    }
  }
}