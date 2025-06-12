import 'order_detail.dart'; // <-- BARU: Import model OrderDetail

class Order {
  final int id;
  final String idUser;
  final double totalPrice;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime createdAt;
  final List<OrderDetail> details; 

  Order({
    required this.id,
    required this.idUser,

    required this.totalPrice,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
    this.details = const [], 
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var detailsList = <OrderDetail>[];
    if (json['order_details'] != null) {
      detailsList = (json['order_details'] as List)
          .map((detailJson) => OrderDetail.fromJson(detailJson))
          .toList();
    }

    return Order(
      id: json['id'],
      idUser: json['id_user'],
      totalPrice: (json['total_price'] as num).toDouble(),
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerAddress: json['customer_address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      details: detailsList, // Masukkan list detail yang sudah diparsing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_price': totalPrice,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'status': status,
    };
  }
}