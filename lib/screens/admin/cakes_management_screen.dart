import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/cake.dart';
import 'add_edit_cake_screen.dart';

class CakesManagementScreen extends StatefulWidget {
  const CakesManagementScreen({super.key});

  @override
  State<CakesManagementScreen> createState() => _CakesManagementScreenState();
}

class _CakesManagementScreenState extends State<CakesManagementScreen> {
  List<Cake> cakes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCakes();
  }

  Future<void> _loadCakes() async {
    try {
      final response = await supabase
          .from('cakes')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        cakes = response.map<Cake>((json) => Cake.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cakes: $error')),
        );
      }
    }
  }

  Future<void> _deleteCake(int cakeId) async {
    try {
      await supabase.from('cakes').delete().eq('id', cakeId);
      _loadCakes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cake deleted successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting cake: $error')),
        );
      }
    }
  }

  void _showDeleteDialog(Cake cake) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cake'),
        content: Text('Are you sure you want to delete "${cake.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCake(cake.id);
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
          : cakes.isEmpty
              ? const Center(
                  child: Text(
                    'No cakes available',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCakes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cakes.length,
                    itemBuilder: (context, index) {
                      final cake = cakes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: cake.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      cake.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.cake,
                                          color: Colors.brown,
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
                                    Icons.cake,
                                    color: Colors.brown,
                                  ),
                          ),
                          title: Text(cake.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cake.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${cake.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditCakeScreen(cake: cake),
                                  ),
                                ).then((_) => _loadCakes());
                              } else if (value == 'delete') {
                                _showDeleteDialog(cake);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditCakeScreen(),
            ),
          ).then((_) => _loadCakes());
        },
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
