import 'package:flutter/material.dart';
import '../../models/cake.dart';
import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import 'checkout_screen.dart';

class CakeDetailScreen extends StatefulWidget {
  final Cake cake;
  const CakeDetailScreen({super.key, required this.cake});

  @override
  State<CakeDetailScreen> createState() => _CakeDetailScreenState();
}

class _CakeDetailScreenState extends State<CakeDetailScreen> {
  final CartService _cartService = CartService();
  int _quantity = 1;
  bool _isAddingToCart = false;

// add to cart
  Future<void> _addToCart() async {
    setState(() => _isAddingToCart = true);
    try {
      await _cartService.addToCart(widget.cake, _quantity);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.cake.name} ditambahkan ke keranjang!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  void _buyNow() {
    final cartItem = CartItem(
      id: 0, 
      quantity: _quantity,
      cake: widget.cake,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(directBuyItems: [cartItem]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  child: Hero(
                    tag:
                        'cake_image_${widget.cake.id}', // Untuk animasi transisi
                    child: widget.cake.imageUrl != null
                        ? Image.network(widget.cake.imageUrl!,
                            fit: BoxFit.cover)
                        : const Center(
                            child: Icon(Icons.cake,
                                size: 100, color: Colors.grey)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.cake.name,
                          style: textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${widget.cake.price.toStringAsFixed(0)}',
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.brown.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Deskripsi',
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.cake.description,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: Colors.black54, height: 1.5)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Jumlah',
                              style: textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: _quantity > 1
                                      ? () => setState(() => _quantity--)
                                      : null,
                                ),
                                Text(_quantity.toString(),
                                    style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => setState(() => _quantity++),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16)
            .copyWith(bottom: MediaQuery.of(context).padding.bottom + 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                icon: _isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(
                        Icons.add_shopping_cart_outlined,
                        color: Colors.brown,
                      ),
                label: const Text('Keranjang'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  side: BorderSide(color: Colors.brown.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isAddingToCart ? null : _addToCart,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                child: const Text('Beli Sekarang'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _buyNow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
