class StockModel {
  final String symbol;
  final String stckname;
  final double ltp;
  final double open;
  final double close;
  final double high;
  final double low;
  final int volume;
  final double priceChange;
  final double percentChange;
  final bool isUp;

  StockModel({
    required this.symbol,
    required this.stckname,
    required this.ltp,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    required this.volume,
    required this.priceChange,
    required this.percentChange,
    required this.isUp,
  });

  String get priceChangeFormatted => '\₹${priceChange.toStringAsFixed(2)}';
  String get percentChangeFormatted =>
      '${percentChange > 0 ? '+' : ''}${percentChange.toStringAsFixed(2)}%';

  factory StockModel.fromJson(Map<String, dynamic> json) {
    final double ltp = json['ltp'].toDouble();
    final double pc = json['pc'].toDouble();
    final double priceChange = ltp - pc;
    final double percentChange = json['pcnt'].toDouble();

    return StockModel(
      symbol: json['symbol'],
      stckname: json['symbol'], // We'll update this from indicators data
      ltp: ltp,
      open: json['o'].toDouble(),
      close: ltp, // Use LTP as current close
      high: json['h'].toDouble(),
      low: json['l'].toDouble(),
      volume: json['v'],
      priceChange: priceChange,
      percentChange: percentChange,
      isUp: priceChange >= 0,
    );
  }
}

class IndicatorModel {
  final String stckname;
  final double? rsi14;
  final double? ema10;
  final double? ema20;
  final double? ema50;
  final double? sma10;
  final double? sma20;
  final double? sma50;

  IndicatorModel({
    required this.stckname,
    this.rsi14,
    this.ema10,
    this.ema20,
    this.ema50,
    this.sma10,
    this.sma20,
    this.sma50,
  });

  factory IndicatorModel.fromJson(Map<String, dynamic> json) {
    return IndicatorModel(
      stckname: json['stckname'],
      rsi14: json['rsi14']?.toDouble(),
      ema10: json['ema10']?.toDouble(),
      ema20: json['ema20']?.toDouble(),
      ema50: json['ema50']?.toDouble(),
      sma10: json['sma10']?.toDouble(),
      sma20: json['sma20']?.toDouble(),
      sma50: json['sma50']?.toDouble(),
    );
  }
}

class ChartData {
  final int timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  ChartData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      timestamp: json['Timestamp'],
      open: json['Open'].toDouble(),
      high: json['High'].toDouble(),
      low: json['Low'].toDouble(),
      close: json['Close'].toDouble(),
      volume: json['Volume'] ?? 0,
    );
  }

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(timestamp);
}
