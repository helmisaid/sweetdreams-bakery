import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/user_profile.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  List<UserProfile> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('id, id_user, role, created_at')
          .order('created_at', ascending: false);

      final List<UserProfile> loadedUsers = [];
      for (var profile in response) {
        try {
          loadedUsers.add(UserProfile(
            id: profile['id'],
            idUser: profile['id_user'],
            email: profile['email'], 
            role: profile['role'] ?? 'user',
            createdAt: DateTime.parse(profile['created_at']),
          ));
        } catch (e) {
          loadedUsers.add(UserProfile(
            id: profile['id'],
            idUser: profile['id_user'],
            email: 'Unknown',
            role: profile['role'] ?? 'user',
            createdAt: DateTime.parse(profile['created_at']),
          ));
        }
      }

      setState(() {
        users = loadedUsers;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $error')),
        );
      }
    }
  }

  Future<void> _updateUserRole(int profileId, String newRole) async {
    try {
      await supabase
          .from('profiles')
          .update({'role': newRole}).eq('id', profileId);

      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User role updated successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user role: $error')),
        );
      }
    }
  }

  Future<void> _deleteUser(int profileId, String userId) async {
    try {
      await supabase.from('orders').delete().eq('id_user', userId);

      await supabase.from('profiles').delete().eq('id', profileId);

      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $error')),
        );
      }
    }
  }

  void _showRoleDialog(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role for ${user.email}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('User'),
              leading: Radio<String>(
                value: 'user',
                groupValue: user.role,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) _updateUserRole(user.id, value);
                },
              ),
            ),
            ListTile(
              title: const Text('Admin'),
              leading: Radio<String>(
                value: 'admin',
                groupValue: user.role,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) _updateUserRole(user.id, value);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete user "${user.email}"?\n\nThis will also delete all their orders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user.id, user.idUser);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user.role == 'admin'
                                ? Colors.red[100]
                                : Colors.blue[100],
                            child: Icon(
                              user.role == 'admin'
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: user.role == 'admin'
                                  ? Colors.red[700]
                                  : Colors.blue[700],
                            ),
                          ),
                          title: Text(user.email),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Role: ${user.role.toUpperCase()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: user.role == 'admin'
                                      ? Colors.red[700]
                                      : Colors.blue[700],
                                ),
                              ),
                              Text(
                                'Joined: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'change_role',
                                child: Row(
                                  children: [
                                    Icon(Icons.swap_horiz),
                                    SizedBox(width: 8),
                                    Text('Change Role'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'change_role') {
                                _showRoleDialog(user);
                              } else if (value == 'delete') {
                                _showDeleteDialog(user);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
