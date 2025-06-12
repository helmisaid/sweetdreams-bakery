import 'package:mini_project_bnsp/models/cake.dart';

class OrderDetail {
  final int id;
  final int orderId;
  final int cakeId;
  final int quantity;
  final double priceAtOrder;
  final Cake? cake; 

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.cakeId,
    required this.quantity,
    required this.priceAtOrder,
    this.cake,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      orderId: json['order_id'],
      cakeId: json['cake_id'],
      quantity: json['quantity'],
      priceAtOrder: (json['price_at_order'] as num).toDouble(),
      // Jika ada data join 'cakes', buat objek Cake
      cake: json['cakes'] != null ? Cake.fromJson(json['cakes']) : null,
    );
  }
}
