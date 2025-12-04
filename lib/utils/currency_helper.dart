class CurrencyHelper {
  static String formatRupiah(double usdPrice) {
    const double exchangeRate = 16000;
    if (usdPrice <= 0.0) return 'GRATIS';
    
    int priceInIdr = (usdPrice * exchangeRate).round();
    String idrString = priceInIdr.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = idrString.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    
    return 'Rp $result';
  }
}