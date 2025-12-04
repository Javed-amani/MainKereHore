class GameDeal {
  final String dealID;
  final String title;
  final String thumb;
  final double salePrice;
  final double normalPrice;
  final double savings;
  final String storeID;
  final int lastChange;
  final String? steamAppID;
  
  // Property tambahan untuk wishlist
  final int? databaseId; 

  GameDeal({
    required this.dealID,
    required this.title,
    required this.thumb,
    required this.salePrice,
    required this.normalPrice,
    required this.savings,
    required this.storeID,
    this.lastChange = 0,
    this.steamAppID,
    this.databaseId,
  });

  // Dari API CheapShark
  factory GameDeal.fromJson(Map<String, dynamic> json) {
    return GameDeal(
      dealID: json['dealID'] ?? '',
      title: json['title'] ?? 'Unknown',
      thumb: json['thumb'] ?? '',
      salePrice: double.tryParse(json['salePrice'].toString()) ?? 0.0,
      normalPrice: double.tryParse(json['normalPrice'].toString()) ?? 0.0,
      savings: double.tryParse(json['savings'].toString()) ?? 0.0,
      storeID: json['storeID'] ?? '1',
      lastChange: int.tryParse(json['lastChange'].toString()) ?? 0,
      steamAppID: json['steamAppID'],
    );
  }

  // Dari Supabase
  factory GameDeal.fromSupabase(Map<String, dynamic> json) {
    return GameDeal(
      databaseId: json['id'],
      dealID: json['deal_id'] ?? '',
      title: json['game_title'] ?? '',
      thumb: json['thumb_url'] ?? '',
      salePrice: double.tryParse(json['sale_price'].toString()) ?? 0.0,
      normalPrice: 0.0, // Supabase tidak simpan normal price di schema lama
      savings: 0.0,
      storeID: json['store_id'] ?? '1',
    );
  }

  Map<String, dynamic> toSupabaseMap(String userId) {
    return {
      'user_id': userId,
      'game_title': title,
      'sale_price': salePrice,
      'deal_id': dealID,
      'store_id': storeID,
      'thumb_url': thumb,
    };
  }
}