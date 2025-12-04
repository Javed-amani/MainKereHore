import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_deal.dart';

class ApiService {
  static const String _baseUrl = 'https://www.cheapshark.com/api/1.0';
  final Map<String, List<String>> _steamGenreCache = {};

  Future<List<GameDeal>> fetchDeals({
    String query = '',
    String genre = 'All',
    double minSavings = 0,
    bool onlyFree = false,
  }) async {
    String url = '$_baseUrl/deals?storeID=1,7,8,25&onSale=1';
    
    if (query.isNotEmpty) {
      url += '&title=$query&pageSize=30';
    } else if (genre != 'All') {
      url += '&pageSize=60&sortBy=Metacritic'; 
    } else {
      url += '&pageSize=30&sortBy=Savings';
    }

    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      List<dynamic> rawData = json.decode(response.body);
      
      // Parsing ke Model
      List<GameDeal> deals = rawData.map((d) => GameDeal.fromJson(d)).toList();

      // Filter Client Side (Harga & Savings)
      deals = deals.where((deal) {
        if (onlyFree) return deal.salePrice == 0.00;
        return deal.savings >= minSavings;
      }).toList();

      // Filter Genre (Steam Logic)
      if (genre != 'All' && query.isEmpty) {
        return await _filterBySteamGenre(deals, genre);
      }

      return deals;
    } else {
      throw Exception("Gagal mengambil data");
    }
  }

  Future<List<GameDeal>> _filterBySteamGenre(List<GameDeal> initialDeals, String genre) async {
    List<GameDeal> validDeals = [];
    int batchSize = 10;
    
    // Batch processing
    for (var i = 0; i < initialDeals.length; i += batchSize) {
      var end = (i + batchSize < initialDeals.length) ? i + batchSize : initialDeals.length;
      var batch = initialDeals.sublist(i, end);
      
      String appIds = batch
          .map((d) => d.steamAppID)
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
            final appId = deal.steamAppID;
            bool isMatch = false;
            
            if (appId == null) {
               isMatch = true;
            } else if (_steamGenreCache.containsKey(appId)) {
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
}