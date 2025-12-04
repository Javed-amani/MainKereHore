import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_deal.dart';
import '../services/api_service.dart';
import '../services/wishlist_service.dart';
import '../services/auth_service.dart';
import '../utils/theme_notifier.dart';
import '../config/app_constants.dart';
import '../widgets/game_card.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});
  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  final ApiService _apiService = ApiService();
  final WishlistService _wishlistService = WishlistService();
  final AuthService _authService = AuthService();

  List<GameDeal> deals = [];
  bool isLoading = false;
  String loadingMessage = '';
  
  bool isGridView = false;
  double minSavings = 50.0;
  bool onlyFree = false;
  String selectedGenre = 'All';
  final TextEditingController _searchController = TextEditingController();

  Map<String, int> _savedStatus = {}; 
  late final StreamSubscription _savedDealsSubscription;

  @override
  void initState() {
    super.initState();
    fetchDeals();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    _savedDealsSubscription.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _setupRealtimeListener() {
    _savedDealsSubscription = _wishlistService.getWishlistStream().listen((List<Map<String, dynamic>> data) {
      if (mounted) {
        setState(() {
          _savedStatus = {
            for (var item in data) item['deal_id'] as String: item['id'] as int
          };
        });
      }
    });
  }

  Future<void> fetchDeals() async {
    setState(() {
      isLoading = true;
      loadingMessage = selectedGenre == 'All' ? 'Mencari diskon...' : 'Memvalidasi genre $selectedGenre di Steam...';
    });
    
    try {
      final result = await _apiService.fetchDeals(
        query: _searchController.text,
        genre: selectedGenre,
        minSavings: minSavings,
        onlyFree: onlyFree,
      );
      
      if (mounted) {
        setState(() {
          deals = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleWishlist(GameDeal deal) async {
    final dealID = deal.dealID;
    final isAlreadySaved = _savedStatus.containsKey(dealID);
    
    // 1. UPDATE UI INSTAN (Optimistic)
    setState(() {
      if (isAlreadySaved) {
        _savedStatus.remove(dealID); 
      } else {
        _savedStatus[dealID] = -1; 
      }
    });

    // 2. KIRIM REQUEST KE SERVER
    try {
      if (isAlreadySaved) {
        await _wishlistService.removeFromWishlistByDealID(dealID);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dihapus dari wishlist'), duration: Duration(seconds: 1)));
      } else {
        await _wishlistService.addToWishlist(deal);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disimpan!'), duration: Duration(seconds: 1)));
      }
    } catch (e) {
      if (mounted) {
        // Revert UI if fail
        setState(() {
          if (isAlreadySaved) {
            _savedStatus[dealID] = 123; 
          } else {
            _savedStatus.remove(dealID);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memproses'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildGenreSelector(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.genres.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final genre = AppConstants.genres[index];
          final isSelected = selectedGenre == genre;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  selectedGenre = genre;
                  _searchController.clear();
                });
                fetchDeals();
              },
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              selectedColor: isDark ? Colors.white : Colors.black,
              checkmarkColor: isDark ? Colors.black : Colors.white,
              labelStyle: TextStyle(
                color: isSelected 
                  ? (isDark ? Colors.black : Colors.white) 
                  : (isDark ? Colors.grey : Colors.black54)
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Deals', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => isGridView = !isGridView),
          ),
           IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari game spesifik...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    fetchDeals();
                  },
                ),
              ),
              onSubmitted: (_) {
                setState(() => selectedGenre = 'All');
                fetchDeals();
              },
            ),
          ),
          
          _buildGenreSelector(isDark),
          const SizedBox(height: 10),

          // --- FILTER UI ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        onlyFree ? 'Mode: Gratis 100%' : 'Diskon Min: ${minSavings.round()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: isDark ? Colors.white : Colors.black,
                          thumbColor: isDark ? Colors.white : Colors.black,
                          inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
                        ),
                        child: Slider(
                          value: minSavings,
                          min: 0,
                          max: 100,
                          onChanged: onlyFree ? null : (v) => setState(() => minSavings = v),
                          onChangeEnd: (_) => fetchDeals(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: const Text('GRATIS'),
                  selected: onlyFree,
                  onSelected: (val) {
                    setState(() {
                      onlyFree = val;
                      if(val) minSavings = 0;
                    });
                    fetchDeals();
                  },
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  selectedColor: Colors.pinkAccent,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(color: onlyFree ? Colors.white : (isDark ? Colors.white : Colors.black), fontSize: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- MAIN LIST ---
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: isDark ? Colors.white : Colors.black),
                        const SizedBox(height: 16),
                        Text(loadingMessage, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  )
                : deals.isEmpty 
                  ? const Center(child: Text("Tidak ada deal ditemukan"))
                  : isGridView 
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.70, 
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: deals.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final deal = deals[index];
                          return GameCard(
                            deal: deal,
                            isSaved: _savedStatus.containsKey(deal.dealID),
                            onToggleSave: () => _toggleWishlist(deal),
                            isGrid: true,
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: deals.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final deal = deals[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GameCard(
                              deal: deal,
                              isSaved: _savedStatus.containsKey(deal.dealID),
                              onToggleSave: () => _toggleWishlist(deal),
                              isGrid: false,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}