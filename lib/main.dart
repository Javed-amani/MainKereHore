import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async'; // StreamSubscription

// --- CONFIG ---
const supabaseUrl = 'https://kvmygwutvbswzgaluhrb.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt2bXlnd3V0dmJzd3pnYWx1aHJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0NDg5ODMsImV4cCI6MjA4MDAyNDk4M30.V1YqpJMFLSM4GnMKAjKhkDicDEGjv_S_2bRHrkudXWY';

// Global Theme Notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const GameDealsApp());
}

class GameDealsApp extends StatelessWidget {
  const GameDealsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Game Deals Hunter',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          // --- LIGHT THEME ---
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.black,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            fontFamily: 'Roboto',
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black12),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: Colors.black12,
              labelTextStyle: WidgetStateProperty.all(const TextStyle(color: Colors.black)),
              iconTheme: WidgetStateProperty.all(const IconThemeData(color: Colors.black)),
            ),
          ),
          // --- DARK THEME ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.white,
            scaffoldBackgroundColor: Colors.black,
            useMaterial3: true,
            fontFamily: 'Roboto',
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: Colors.black,
              elevation: 4,
              shadowColor: Colors.white24,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.black,
              indicatorColor: Colors.white24,
              labelTextStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
              iconTheme: WidgetStateProperty.all(const IconThemeData(color: Colors.white)),
            ),
          ),
          home: const AuthGate(),
        );
      },
    );
  }
}

// --- AUTH GATE ---
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          return const MainScreen();
        }
        return const LoginPage();
      },
    );
  }
}

// --- LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLoginMode) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return AlertDialog(
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                title: Text('Registrasi Berhasil', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                content: Text('Silakan cek email Anda untuk verifikasi akun sebelum login.', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800])),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  ),
                ],
              );
            },
          );
          setState(() => _isLoginMode = true);
        }
      }
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mengganti Icon dengan Icon Uang Kertas (Money)
                Icon(Icons.money, size: 80, color: isDark ? Colors.white : Colors.black),
                const SizedBox(height: 16),
                Text(
                  'Main Kere Hore',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLoginMode ? 'Daftar Game Kere Hore!' : 'Gabung sekarang!',
                  style: TextStyle(color: isDark ? Colors.grey : Colors.grey[700]),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? Border.all(color: Colors.white24) : Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined), hintText: 'Email'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), hintText: 'Password'),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : Colors.black,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading 
                            ? CircularProgressIndicator(color: isDark ? Colors.black : Colors.white) 
                            : Text(_isLoginMode ? 'LOGIN' : 'REGISTER', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                  child: Text(
                    _isLoginMode ? 'Belum punya akun? Daftar' : 'Sudah punya akun? Login',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- MAIN SCREEN ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;
  
  final List<Widget> _pages = [
    const DealsPage(),
    const WishlistPage(),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animController.forward();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _animController.reset();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animController,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: Colors.pink),
            label: 'Wishlist',
          ),
        ],
      ),
    );
  }
}

// --- DEALS PAGE ---
class DealsPage extends StatefulWidget {
  const DealsPage({super.key});
  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  List<dynamic> deals = [];
  bool isLoading = false;
  String loadingMessage = '';
  
  bool isGridView = false;
  double minSavings = 50.0;
  bool onlyFree = false;
  String selectedGenre = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> genres = ['All', 'RPG', 'Action', 'Strategy', 'Adventure', 'Horror', 'Racing', 'Simulation'];
  final Map<String, String> storeNames = {
    "1": "Steam", "7": "GOG", "8": "EA", "25": "Epic"
  };

  final Map<String, List<String>> _steamGenreCache = {};

  // --- STATE WISHLIST REALTIME ---
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
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _savedDealsSubscription = Supabase.instance.client
          .from('saved_deals')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .listen((List<Map<String, dynamic>> data) {
            if (mounted) {
              setState(() {
                _savedStatus = {
                  for (var item in data) item['deal_id'] as String: item['id'] as int
                };
              });
            }
          });
    }
  }

  // --- OPTIMISTIC TOGGLE WISHLIST ---
  Future<void> _toggleWishlist(Map<String, dynamic> deal) async {
    final dealID = deal['dealID'];
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final isAlreadySaved = _savedStatus.containsKey(dealID);
    
    // 1. UPDATE UI INSTAN (Optimistic)
    setState(() {
      if (isAlreadySaved) {
        _savedStatus.remove(dealID); // Hilangkan merah
      } else {
        _savedStatus[dealID] = -1; // Jadikan merah (dummy ID)
      }
    });

    // 2. KIRIM REQUEST KE SERVER
    try {
      if (isAlreadySaved) {
        // Hapus
        // Note: Kita butuh ID aslinya. Jika baru saja ditambah dan belum sync stream, 
        // mungkin IDnya masih -1. Tapi untuk kasus normal ini bekerja.
        // Jika stream listener cepat, ID asli sudah ada.
        
        // Cari ID database dari list stream atau query ulang jika perlu, 
        // tapi di sini kita asumsi user tidak klik secepat kilat (add -> remove dalam 0.1ms).
        // Kalau ID hilang karena remove optimistic di atas, kita harusnya simpan dulu.
        // PERBAIKAN: Ambil ID dari snapshot Stream/Cache sebelum dihapus dari map lokal UI.
        // Namun karena kita sudah hapus di setState atas, kita query delete berdasarkan deal_id & user_id (lebih aman)
        
        await Supabase.instance.client
            .from('saved_deals')
            .delete()
            .eq('user_id', user.id)
            .eq('deal_id', dealID);
            
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dihapus dari wishlist'), duration: Duration(seconds: 1)));
      } else {
        // Simpan
        await Supabase.instance.client.from('saved_deals').insert({
          'user_id': user.id,
          'game_title': deal['title'],
          'sale_price': deal['salePrice'],
          'deal_id': deal['dealID'],
          'store_id': deal['storeID'],
          'thumb_url': deal['thumb'],
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disimpan!'), duration: Duration(seconds: 1)));
      }
    } catch (e) {
      // Jika gagal, kembalikan status UI
      if (mounted) {
        setState(() {
          if (isAlreadySaved) {
            _savedStatus[dealID] = 123; // Restore (ID dummy gpp, nanti stream refresh)
          } else {
            _savedStatus.remove(dealID);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memproses'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> fetchDeals() async {
    setState(() {
      isLoading = true;
      loadingMessage = selectedGenre == 'All' ? 'Mencari diskon...' : 'Memvalidasi genre $selectedGenre di Steam...';
    });
    
    try {
      String url = 'https://www.cheapshark.com/api/1.0/deals?storeID=1,7,8,25&onSale=1';
      String searchQuery = _searchController.text;
      
      if (searchQuery.isNotEmpty) {
        url += '&title=$searchQuery&pageSize=30';
      } else if (selectedGenre != 'All') {
        url += '&pageSize=60&sortBy=Metacritic'; 
      } else {
        url += '&pageSize=30&sortBy=Savings';
      }

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        List<dynamic> rawData = json.decode(response.body);
        
        List<dynamic> filtered = rawData.where((deal) {
          final savings = double.tryParse(deal['savings'].toString()) ?? 0;
          final price = double.tryParse(deal['salePrice'].toString()) ?? 100;
          if (onlyFree) return price == 0.00;
          return savings >= minSavings;
        }).toList();

        if (selectedGenre != 'All' && searchQuery.isEmpty) {
          filtered = await _filterBySteamGenre(filtered, selectedGenre);
        }

        if (mounted) {
          setState(() {
            deals = filtered;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      if(mounted) setState(() => isLoading = false);
    }
  }

  Future<List<dynamic>> _filterBySteamGenre(List<dynamic> initialDeals, String genre) async {
    List<dynamic> validDeals = [];
    int batchSize = 10;
    for (var i = 0; i < initialDeals.length; i += batchSize) {
      if (!mounted) break;
      var end = (i + batchSize < initialDeals.length) ? i + batchSize : initialDeals.length;
      var batch = initialDeals.sublist(i, end);
      
      String appIds = batch
          .map((d) => d['steamAppID'])
          .where((id) => id != null && id != "")
          .join(',');

      if (appIds.isEmpty) {
        validDeals.addAll(batch);
        continue;
      }

      try {
        final steamResponse = await http.get(
          Uri.parse('https://store.steampowered.com/api/appdetails?appids=$appIds&filters=genres'),
        );

        if (steamResponse.statusCode == 200) {
          final steamData = json.decode(steamResponse.body);
          
          for (var deal in batch) {
            final appId = deal['steamAppID'];
            bool isMatch = false;
            
            if (_steamGenreCache.containsKey(appId)) {
               isMatch = _steamGenreCache[appId]!.contains(genre);
            } 
            else if (steamData[appId] != null && steamData[appId]['success'] == true) {
              final gameData = steamData[appId]['data'];
              if (gameData != null && gameData['genres'] != null) {
                List<dynamic> genres = gameData['genres'];
                List<String> genreList = genres.map((g) => g['description'].toString()).toList();
                _steamGenreCache[appId] = genreList;
                isMatch = genreList.any((g) => g.toLowerCase().contains(genre.toLowerCase()));
              }
            } else {
              isMatch = true; 
            }

            if (isMatch) validDeals.add(deal);
          }
        } else {
          validDeals.addAll(batch);
        }
      } catch (e) {
        validDeals.addAll(batch);
      }
    }
    return validDeals;
  }

  Widget _buildGenreSelector(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final genre = genres[index];
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

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
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
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
            tooltip: isGridView ? 'Switch to List' : 'Switch to Grid',
          ),
           IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Logout',
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
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: deals.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final deal = deals[index];
                            final dealID = deal['dealID'];
                            final isSaved = _savedStatus.containsKey(dealID);

                            return GameCard(
                              title: deal['title'],
                              thumb: deal['thumb'],
                              normalPrice: '\$${deal['normalPrice']}',
                              salePrice: deal['salePrice'] == '0.00' ? 'FREE' : '\$${deal['salePrice']}',
                              savings: deal['savings'],
                              storeName: storeNames[deal['storeID']] ?? 'Store',
                              onTapBtn: () => _toggleWishlist(deal),
                              btnIcon: isSaved ? Icons.favorite : Icons.favorite_border,
                              isSaved: isSaved, 
                              onWeb: () => launchUrl(Uri.parse('https://www.cheapshark.com/redirect?dealID=$dealID')),
                              isGrid: true,
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: deals.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final deal = deals[index];
                            final dealID = deal['dealID'];
                            final isSaved = _savedStatus.containsKey(dealID);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GameCard(
                                title: deal['title'],
                                thumb: deal['thumb'],
                                normalPrice: '\$${deal['normalPrice']}',
                                salePrice: deal['salePrice'] == '0.00' ? 'FREE' : '\$${deal['salePrice']}',
                                savings: deal['savings'],
                                storeName: storeNames[deal['storeID']] ?? 'Store',
                                onTapBtn: () => _toggleWishlist(deal),
                                btnIcon: isSaved ? Icons.favorite : Icons.favorite_border,
                                isSaved: isSaved,
                                onWeb: () => launchUrl(Uri.parse('https://www.cheapshark.com/redirect?dealID=$dealID')),
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

// --- WISHLIST PAGE (Diubah jadi StatefulWidget agar bisa hapus instan) ---
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> _wishlist = [];
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

  // Load awal dan Subscribe
  void _loadWishlist() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Stream agar tetap update jika ditambah dari halaman discover
      _subscription = Supabase.instance.client
          .from('saved_deals')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .order('created_at')
          .listen((data) {
        if (mounted) {
          setState(() {
            _wishlist = data;
            _isLoading = false;
          });
        }
      });
    }
  }

  // Hapus Instan (Optimistic)
  Future<void> _deleteItem(int index, int id) async {
    // 1. Konfirmasi
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

    if (confirm != true) return;

    // 2. Simpan backup data jika gagal
    final backupItem = _wishlist[index];

    // 3. HAPUS DARI UI LANGSUNG (Optimistic)
    setState(() {
      _wishlist.removeAt(index);
    });

    // 4. Hapus dari Database
    try {
      await Supabase.instance.client.from('saved_deals').delete().eq('id', id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dihapus'), duration: Duration(milliseconds: 500)));
    } catch (e) {
      // Jika gagal, kembalikan ke UI
      if (mounted) {
        setState(() {
          _wishlist.insert(index, backupItem);
        });
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
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
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
                  title: item['game_title'],
                  thumb: item['thumb_url'],
                  normalPrice: '', 
                  salePrice: item['sale_price'] == '0.00' ? 'FREE' : '\$${item['sale_price']}',
                  savings: '0',
                  storeName: 'Saved',
                  btnIcon: Icons.delete_outline,
                  onTapBtn: () => _deleteItem(index, item['id']),
                  onWeb: () => launchUrl(Uri.parse('https://www.cheapshark.com/redirect?dealID=${item['deal_id']}')),
                  isWishlist: true,
                  isSaved: true,
                  isGrid: false,
                ),
              );
            },
          ),
    );
  }
}

// --- AESTHETIC GAME CARD ---
class GameCard extends StatelessWidget {
  final String title, thumb, normalPrice, salePrice, savings, storeName;
  final VoidCallback onTapBtn;
  final VoidCallback onWeb;
  final IconData btnIcon;
  final bool isWishlist;
  final bool isGrid;
  final bool isSaved; // Parameter baru untuk warna hati

  const GameCard({
    super.key,
    required this.title,
    required this.thumb,
    required this.normalPrice,
    required this.salePrice,
    required this.savings,
    required this.storeName,
    required this.onTapBtn,
    required this.onWeb,
    required this.btnIcon,
    this.isWishlist = false,
    this.isGrid = false,
    this.isSaved = false, // Default false
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget contentSection = Padding(
      padding: EdgeInsets.all(isGrid ? 10 : 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: isGrid ? 13 : 16),
                      maxLines: isGrid ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap( 
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if(normalPrice.isNotEmpty)
                          Text(normalPrice, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10)),
                        if(normalPrice.isNotEmpty) const SizedBox(width: 4),
                        Text(salePrice, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: isGrid ? 14 : 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: onTapBtn,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: EdgeInsets.all(isGrid ? 6 : 8),
                  decoration: BoxDecoration(
                    color: isWishlist 
                        ? Colors.pink.withOpacity(0.1) 
                        : (isSaved 
                            ? Colors.pink.withOpacity(0.1) // Merah muda jika tersimpan
                            : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    btnIcon, 
                    color: isWishlist || isSaved ? Colors.pink : Colors.grey, // Ikon Pink jika tersimpan
                    size: isGrid ? 16 : 20
                  ),
                ),
              ),
              SizedBox(width: isGrid ? 4 : 8),
              
              isGrid 
              ? InkWell(
                  onTap: onWeb,
                  child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : Colors.black,
                        shape: BoxShape.circle
                      ),
                      child: Icon(Icons.arrow_forward, size: 12, color: isDark ? Colors.black : Colors.white),
                  ),
                )
              : ElevatedButton(
                  onPressed: onWeb,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text('GET', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          )
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: isGrid ? 110 : 140,
                  width: double.infinity,
                  child: Image.network(
                    thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Container(
                      color: isDark ? Colors.white10 : Colors.black12,
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(storeName, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                if (!isWishlist && savings != '0')
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('-${double.parse(savings).round()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black)),
                  ),
                ),
              ],
            ),
            
            isGrid 
              ? Expanded(child: contentSection)
              : contentSection,
          ],
        ),
      ),
    );
  }
}