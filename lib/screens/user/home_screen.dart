import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/cake.dart';
import '../../auth/auth_required_state.dart';
import '../../services/cart_service.dart';
import 'cake_detail_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends AuthRequiredState<HomeScreen> {
  final CartService _cartService = CartService();
  bool _isAddingToCart = false;

  List<Cake> cakes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
    _loadInitialData();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _loadInitialData() {
    _loadCakes();
    _cartService.fetchCartItemCount();
  }

  Future<void> _loadCakes() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('cakes')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          cakes = response.map<Cake>((json) => Cake.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => isLoading = false);
        showSnackBar('Error loading cakes: $error', isError: true);
      }
    }
  }

  Future<void> _handleAddToCart(Cake cake) async {
    setState(() => _isAddingToCart = true);
    try {
      await _cartService.addToCart(cake, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${cake.name} ditambahkan ke keranjang!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            elevation: 8,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBar('Gagal menambahkan ke keranjang: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E1), // Light amber
              Color(0xFFFFFBF0), // Very light cream
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [

            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading:
                  false, 
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8D6E63), 
                      Color(0xFF6D4C41), 
                      Color(0xFF5D4037), 
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.cake,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Flexible(
                                child: Text(
                                  'Sweet Dreams Bakery',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Color(0x80000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Cart button dengan badge
                            Stack(
                              children: [
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const CartScreen()),
                                    ).then((_) =>
                                        _cartService.fetchCartItemCount());
                                  },
                                ),
                                if (_cartService.itemCount > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5722),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF5722)
                                                .withOpacity(0.4),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      child: Text(
                                        _cartService.itemCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(width: 8),

                            // Logout button
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              onPressed: signOut,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content area
            SliverToBoxAdapter(
              child: isLoading
                  ? Container(
                      height: MediaQuery.of(context).size.height - 200,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF8D6E63),
                              ),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading delicious cakes...',
                              style: TextStyle(
                                color: Color(0xFF8D6E63),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : cakes.isEmpty
                      ? Container(
                          height: MediaQuery.of(context).size.height - 200,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cake_outlined,
                                  size: 80,
                                  color: Color(0xFF8D6E63),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No cakes available',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8D6E63),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Check back later for fresh treats!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF8D6E63),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadCakes,
                          color: const Color(0xFF8D6E63),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  0.8, // Diperbesar untuk memberi ruang lebih
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: cakes.length,
                            itemBuilder: (context, index) {
                              final cake = cakes[index];
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Card(
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white,
                                          Color(0xFFFFFBF0),
                                        ],
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CakeDetailScreen(cake: cake),
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Image section - Fixed height
                                          SizedBox(
                                            height:
                                                120, // Fixed height untuk gambar
                                            child: Stack(
                                              children: [
                                                Hero(
                                                  tag: 'cake_image_${cake.id}',
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 120,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                      ),
                                                      child: cake.imageUrl !=
                                                              null
                                                          ? Image.network(
                                                              cake.imageUrl!,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (_,
                                                                      __,
                                                                      ___) =>
                                                                  Container(
                                                                color: const Color(
                                                                    0xFFF5F5F5),
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  color: Color(
                                                                      0xFF8D6E63),
                                                                  size: 40,
                                                                ),
                                                              ),
                                                            )
                                                          : Container(
                                                              color: const Color(
                                                                  0xFFF5F5F5),
                                                              child: const Icon(
                                                                Icons.cake,
                                                                size: 60,
                                                                color: Color(
                                                                    0xFF8D6E63),
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Cake name
                                                  Text(
                                                    cake.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Color(0xFF2E2E2E),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),

                                                  const SizedBox(height: 6),

                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          const LinearGradient(
                                                        colors: [
                                                          Color(0xFFFFE0B2),
                                                          Color(0xFFFFCC80),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      'Rp ${cake.price.toStringAsFixed(0)}',
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF8D6E63),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),

                                                  const Spacer(),

                                                  SizedBox(
                                                    width: double.infinity,
                                                    height:
                                                        32, 
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            const LinearGradient(
                                                          colors: [
                                                            Color(0xFF8D6E63),
                                                            Color(0xFF6D4C41),
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(
                                                                    0xFF8D6E63)
                                                                .withOpacity(
                                                                    0.3),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child:
                                                          ElevatedButton.icon(
                                                        icon: const Icon(
                                                          Icons
                                                              .add_shopping_cart,
                                                          size: 16,
                                                          color: Colors.white,
                                                        ),
                                                        label: const Text(
                                                          'Keranjang',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          foregroundColor:
                                                              Colors.white,
                                                          shadowColor: Colors
                                                              .transparent,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8),
                                                        ),
                                                        onPressed: _isAddingToCart
                                                            ? null
                                                            : () =>
                                                                _handleAddToCart(
                                                                    cake),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
