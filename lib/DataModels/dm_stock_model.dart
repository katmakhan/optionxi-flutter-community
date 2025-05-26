// First, let's create the DataStockModel class based on your interface
// file: lib/DataModels/dm_stock_model.dart

class DataStockModel {
  final double close;
  final double pclose;
  final double high;
  final double low;
  final double open;
  final double pcnt;
  final String sec;
  final String stckname;
  final int vol;
  final String symbol; // Added symbol field which appears to be used in UI

  DataStockModel({
    required this.close,
    required this.pclose,
    required this.high,
    required this.low,
    required this.open,
    required this.pcnt,
    required this.sec,
    required this.stckname,
    required this.vol,
    required this.symbol,
  });

  factory DataStockModel.fromJson(Map<String, dynamic> json) {
    return DataStockModel(
      close: (json['ltp'] ?? 0.0).toDouble(), // ltp → close
      pclose: (json['pc'] ?? 0.0).toDouble(), // pc → pclose
      high: (json['h'] ?? 0.0).toDouble(), // h → high
      low: (json['l'] ?? 0.0).toDouble(), // l → low
      open: (json['o'] ?? 0.0).toDouble(), // o → open
      pcnt: (json['pcnt'] ?? 0.0).toDouble(), // pcnt → pcnt
      sec: json['sec'] ?? '', // sec (missing from table? will be empty)
      stckname: json['stckname'] ??
          '', // stckname (missing from table? will be empty)
      vol: (json['v'] ?? 0) as int, // v → vol
      symbol: json['symbol'] ?? '', // symbol
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ltp': close,
      'pc': pclose,
      'h': high,
      'l': low,
      'o': open,
      'pcnt': pcnt,
      'sec': sec,
      'stckname': stckname,
      'v': vol,
      'symbol': symbol,
    };
  }

  // Helper method to determine if stock is up or down
  bool get isUp => close >= pclose;

  // Helper method to get price change
  double get priceChange => close - pclose;

  // Helper method to format price change to string with sign
  String get priceChangeFormatted => isUp
      ? '+\$${priceChange.toStringAsFixed(2)}'
      : '-\$${priceChange.abs().toStringAsFixed(2)}';

  // Helper method to format percentage change
  String get percentChangeFormatted =>
      isUp ? '+${pcnt.toStringAsFixed(2)}%' : '${pcnt.toStringAsFixed(2)}%';
}
