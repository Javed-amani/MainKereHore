import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_deal.dart';
import '../services/wishlist_service.dart';
import '../utils/theme_notifier.dart';
import '../widgets/game_card.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  List<GameDeal> _wishlist = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _loadWishlist() {
    _subscription = _wishlistService.getWishlistStream().listen((data) {
      if (mounted) {
        setState(() {
          // Convert Map dari Supabase ke Object GameDeal
          _wishlist = data.map((item) => GameDeal.fromSupabase(item)).toList();
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _deleteItem(int index, GameDeal item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text('Hapus Item?', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: Text('Hapus dari wishlist?', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Hapus'),
            ),
          ],
        );
      }
    );

    if (confirm != true || item.databaseId == null) return;

    final backupItem = _wishlist[index];
    setState(() => _wishlist.removeAt(index)); // Optimistic UI

    try {
      await _wishlistService.removeFromWishlistByID(item.databaseId!);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dihapus'), duration: Duration(milliseconds: 500)));
    } catch (e) {
      if (mounted) {
        setState(() => _wishlist.insert(index, backupItem)); // Revert
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
           IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        ],
      ),
      body: _wishlist.isEmpty 
        ? const Center(child: Text("Belum ada game favorit"))
        : ListView.builder(
            itemCount: _wishlist.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = _wishlist[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GameCard(
                  deal: item,
                  onToggleSave: () => _deleteItem(index, item),
                  isWishlistMode: true,
                  isSaved: true,
                ),
              );
            },
          ),
    );
  }
}