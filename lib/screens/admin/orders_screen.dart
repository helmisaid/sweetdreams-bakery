import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../models/order.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? _selectedStatusFilter;
  bool _isSortAscending = false;
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = _fetchOrdersFromSupabase();
    });
  }

  Future<List<Order>> _fetchOrdersFromSupabase() async {
    try {
      var query =
          supabase.from('orders').select('*, order_details(*, cakes(*))');

      if (_selectedStatusFilter != null) {
        query = query.eq('status', _selectedStatusFilter!);
      } else {
        query = query.neq('status', 'in_cart');
      }

      final response =
          await query.order('created_at', ascending: _isSortAscending);

      return response.map<Order>((json) => Order.fromJson(json)).toList();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error loading orders: $error'),
          backgroundColor: Colors.red,
        ));
      }
      return [];
    }
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await supabase
          .from('orders')
          .update({'status': newStatus}).eq('id', orderId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Order #$orderId status updated to $newStatus'),
          backgroundColor: Colors.green));
      setState(() {
        _loadOrders();
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to update status: $error'),
            backgroundColor: Colors.red));
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: TextStyle(color: Colors.black87, height: 1.4))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusFilters = ['pending', 'processing', 'completed', 'cancelled'];

    return Scaffold(
        body: Column(children: [
      Padding(
        padding: const EdgeInsets.all(16.0).copyWith(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter by Status:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(_isSortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward),
                  tooltip: _isSortAscending
                      ? 'Sort Oldest First'
                      : 'Sort Newest First',
                  onPressed: () {
                    setState(() => _isSortAscending = !_isSortAscending);
                    _loadOrders(); // Muat ulang data dengan urutan baru
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedStatusFilter == null,
                    onSelected: (selected) {
                      setState(() => _selectedStatusFilter = null);
                      _loadOrders();
                    },
                  ),
                  const SizedBox(width: 8),
                  ...statusFilters
                      .map((status) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(status.toUpperCase()),
                              selected: _selectedStatusFilter == status,
                              backgroundColor:
                                  _getStatusColor(status).withOpacity(0.1),
                              selectedColor:
                                  _getStatusColor(status).withOpacity(0.3),
                              checkmarkColor: _getStatusColor(status),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) _selectedStatusFilter = status;
                                });
                                _loadOrders();
                              },
                            ),
                          ))
                      .toList(),
                ],
              ),
            )
          ],
        ),
      ),
      Expanded(
        child: FutureBuilder<List<Order>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('Belum ada pesanan.',
                      style: TextStyle(fontSize: 18)));
            }

            final orders = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadOrders();
                });
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final List<String> statusOptions = [
                    'pending',
                    'processing',
                    'completed',
                    'cancelled'
                  ];

                  return Card(
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Order #${order.id}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButton<String>(
                                  value: order.status,
                                  underline: const SizedBox(),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: _getStatusColor(order.status)),
                                  items: statusOptions
                                      .map((String value) =>
                                          DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value.toUpperCase(),
                                                style: TextStyle(
                                                    color:
                                                        _getStatusColor(value),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12)),
                                          ))
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null)
                                      _updateOrderStatus(order.id, newValue);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          const Text("Item Dipesan:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          ...order.details.map((detail) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 4.0),
                              child: Text(
                                '• ${detail.cake?.name ?? 'Nama Kue Error'} (x${detail.quantity})',
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Total Pesanan: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(order.totalPrice)}',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown),
                            ),
                          ),

                          const Divider(height: 24),

                          // Detail Pelanggan
                          const Text("Detail Pelanggan:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.person_outline,
                              order.customerName ?? 'Tidak ada nama'),
                          const SizedBox(height: 4),
                          _buildDetailRow(Icons.phone_outlined,
                              order.customerPhone ?? 'Tidak ada telepon'),
                          const SizedBox(height: 4),
                          _buildDetailRow(Icons.home_outlined,
                              order.customerAddress ?? 'Tidak ada alamat'),

                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Dipesan pada: ${DateFormat('d MMM yyyy, HH:mm').format(order.createdAt.toLocal())}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      )
    ]));
  }
}
