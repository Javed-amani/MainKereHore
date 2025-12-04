class Formatters {
  static String formatRupiah(double usdPrice) {
    const double exchangeRate = 16000;
    if (usdPrice <= 0.0) return 'GRATIS';
    
    int priceInIdr = (usdPrice * exchangeRate).round();
    String idrString = priceInIdr.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = idrString.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    
    return 'Rp $result';
  }

  static String formatTimeInfo(int lastChange) {
    if (lastChange == 0) return '';

    final date = DateTime.fromMillisecondsSinceEpoch(lastChange * 1000);
    final now = DateTime.now();
    final isFuture = date.isAfter(now);
    final diff = isFuture ? date.difference(now) : now.difference(date);

    String timeString;
    if (diff.inDays > 0) {
      timeString = '${diff.inDays} hari';
    } else if (diff.inHours > 0) {
      timeString = '${diff.inHours} jam';
    } else {
      timeString = '${diff.inMinutes} menit';
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final dateStr = '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} ${twoDigits(date.hour)}:${twoDigits(date.minute)}';

    if (isFuture) {
      return 'Berakhir dlm $timeString ($dateStr)';
    } else {
      return 'Update $timeString lalu ($dateStr)';
    }
  }
}