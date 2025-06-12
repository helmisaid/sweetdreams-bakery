import 'package:flutter/material.dart';
import '../../main.dart';
import '../../auth/auth_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final _authService = AuthService();
  String _debugInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        setState(() {
          _debugInfo = 'No user logged in';
        });
        return;
      }

      final role = await _authService.getUserRole();

      // Get profile data directly
      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      setState(() {
        _debugInfo = '''
User ID: ${user.id}
Email: ${user.email}
Role from service: $role
Profile data: ${profileResponse.toString()}
User metadata: ${user.userMetadata.toString()}
''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Info'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Information:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _debugInfo,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDebugInfo,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
