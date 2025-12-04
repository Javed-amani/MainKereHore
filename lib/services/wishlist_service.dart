import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_deal.dart';

class WishlistService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getWishlistStream() {
    final user = _client.auth.currentUser;
    if (user == null) return const Stream.empty();
    
    return _client
        .from('saved_deals')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at'); // Mengembalikan List<Map>
  }

  Future<void> addToWishlist(GameDeal deal) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    
    await _client.from('saved_deals').insert(deal.toSupabaseMap(user.id));
  }

  Future<void> removeFromWishlistByDealID(String dealID) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client
        .from('saved_deals')
        .delete()
        .eq('user_id', user.id)
        .eq('deal_id', dealID);
  }

  Future<void> removeFromWishlistByID(int id) async {
    await _client.from('saved_deals').delete().eq('id', id);
  }
}