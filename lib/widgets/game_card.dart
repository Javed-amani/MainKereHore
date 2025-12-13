import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game_deal.dart';
import '../utils/formatters.dart';
import '../config/app_constants.dart';

class GameCard extends StatelessWidget {
  final GameDeal deal;
  final bool isSaved;
  final bool isWishlistMode;
  final bool isGrid;
  final VoidCallback onToggleSave;

  const GameCard({
    super.key,
    required this.deal,
    required this.onToggleSave,
    this.isSaved = false,
    this.isWishlistMode = false,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storeName = AppConstants.storeNames[deal.storeID] ?? 'Store';
    final timeInfo = Formatters.formatTimeInfo(deal.lastChange);

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
                  mainAxisSize: MainAxisSize.min,
                  children: [
        // Judul Game
        Flexible( // Tambahkan Flexible agar teks menyesuaikan ruang
          child: Text(
            deal.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: isGrid ? 13 : 16),
            maxLines: isGrid ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
                    const SizedBox(height: 4),
                    Wrap( 
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if(deal.normalPrice > 0)
                          Text(Formatters.formatRupiah(deal.normalPrice), style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10)),
                        if(deal.normalPrice > 0) const SizedBox(width: 4),
                        Text(Formatters.formatRupiah(deal.salePrice), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: isGrid ? 14 : 18)),
                      ],
                    ),
                    if (timeInfo.isNotEmpty && !isWishlistMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          timeInfo,
                          style: TextStyle(fontSize: 9, color: isDark ? Colors.grey : Colors.grey[700], fontStyle: FontStyle.italic),
                        ),
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
                onTap: onToggleSave,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: EdgeInsets.all(isGrid ? 6 : 8),
                  decoration: BoxDecoration(
                    color: isWishlistMode || isSaved
                        ? Colors.pink.withOpacity(0.1) 
                        : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isWishlistMode ? Icons.delete_outline : (isSaved ? Icons.favorite : Icons.favorite_border), 
                    color: isWishlistMode || isSaved ? Colors.pink : Colors.grey, 
                    size: isGrid ? 16 : 20
                  ),
                ),
              ),
              SizedBox(width: isGrid ? 4 : 8),
              
              if (isGrid) 
                _buildCircleButton(isDark)
              else 
                _buildRectButton(isDark),
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
                    deal.thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Container(color: isDark ? Colors.white10 : Colors.black12, child: const Icon(Icons.broken_image)),
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
                  top: 8, left: 8,
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
                if (!isWishlistMode && deal.savings > 0)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('-${deal.savings.round()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black)),
                  ),
                ),
              ],
            ),
            
            isGrid ? Expanded(child: contentSection) : contentSection,
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(bool isDark) {
    return InkWell(
      onTap: _launchUrl,
      child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? Colors.white : Colors.black,
            shape: BoxShape.circle
          ),
          child: Icon(Icons.arrow_forward, size: 12, color: isDark ? Colors.black : Colors.white),
      ),
    );
  }

  Widget _buildRectButton(bool isDark) {
    return ElevatedButton(
      onPressed: _launchUrl,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.white : Colors.black,
        foregroundColor: isDark ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      child: const Text('GET', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _launchUrl() {
     launchUrl(Uri.parse('https://www.cheapshark.com/redirect?dealID=${deal.dealID}'));
  }
}