import 'cake.dart';

class CartItem {
  final int id; 
  final int quantity;
  final Cake cake; 

  CartItem({
    required this.id,
    required this.quantity,
    required this.cake,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      quantity: json['quantity'],
      cake: Cake.fromJson(json['cakes']),
    );
  }
}