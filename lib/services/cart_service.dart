import 'package:flutter/material.dart';
import '../main.dart';
import '../models/cake.dart';
import '../models/cart_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartService extends ChangeNotifier {
  int _itemCount = 0;
  int get itemCount => _itemCount;

  Future<void> fetchCartItemCount() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        _itemCount = 0;
      } else {
        final count = await supabase
            .from('cart_items')
            .count(CountOption.exact)
            .eq('user_id', user.id);

        _itemCount = count;
      }
    } catch (e) {
      _itemCount = 0;
      debugPrint("Error fetching cart item count: $e");
    }
    notifyListeners();
  }

  Future<void> addToCart(Cake cake, int quantity) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    try {
      final existingItem = await supabase
          .from('cart_items')
          .select('id, quantity')
          .eq('user_id', user.id)
          .eq('cake_id', cake.id)
          .maybeSingle();
      if (existingItem != null) {
        final newQuantity = existingItem['quantity'] + quantity;
        await supabase
            .from('cart_items')
            .update({'quantity': newQuantity}).eq('id', existingItem['id']);
      } else {
        await supabase.from('cart_items').insert(
            {'user_id': user.id, 'cake_id': cake.id, 'quantity': quantity});
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
    await fetchCartItemCount();
  }

  Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
    } else {
      await supabase
          .from('cart_items')
          .update({'quantity': newQuantity}).eq('id', cartItemId);
    }
    await fetchCartItemCount();
  }

  Future<void> removeFromCart(int cartItemId) async {
    await supabase.from('cart_items').delete().eq('id', cartItemId);
    await fetchCartItemCount();
  }

  Future<void> clearCart() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    await supabase.from('cart_items').delete().eq('user_id', user.id);
    await fetchCartItemCount();
  }

  Future<List<CartItem>> getCartItems() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];
    try {
      final response = await supabase
          .from('cart_items')
          .select('*, cakes(*)')
          .eq('user_id', user.id);
      return response.map((data) => CartItem.fromJson(data)).toList();
    } catch (e) {
      debugPrint("Error getting cart items: $e");
      return [];
    }
  }
}
