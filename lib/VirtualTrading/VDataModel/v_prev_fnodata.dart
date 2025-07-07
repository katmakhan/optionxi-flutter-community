class DataFNOModel {
  final int? id;
  final String symbol;
  final double ltp; // Last Traded Price
  final double o; // Open
  final double pc; // Previous Close
  final double h; // High
  final double l; // Low
  final int v; // Volume
  final double pcnt; // Percentage Change

  // Derived properties
  final String underlying;
  final String expiry;
  final double strikePrice;
  final String optionType; // CE or PE
  final String displayName;

  DataFNOModel({
    this.id,
    required this.symbol,
    required this.ltp,
    required this.o,
    required this.pc,
    required this.h,
    required this.l,
    required this.v,
    required this.pcnt,
  })  : underlying = _extractUnderlying(symbol),
        expiry = _extractExpiry(symbol),
        strikePrice = _extractStrikePrice(symbol),
        optionType = _extractOptionType(symbol),
        displayName = _createDisplayName(symbol);

  factory DataFNOModel.fromJson(Map<String, dynamic> json) {
    return DataFNOModel(
      id: json['id'] as int?,
      symbol: json['symbol'] as String? ?? '',
      ltp: _parseDouble(json['ltp']),
      o: _parseDouble(json['o']),
      pc: _parseDouble(json['pc']),
      h: _parseDouble(json['h']),
      l: _parseDouble(json['l']),
      v: _parseInt(json['v']),
      pcnt: _parseDouble(json['pcnt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'ltp': ltp,
      'o': o,
      'pc': pc,
      'h': h,
      'l': l,
      'v': v,
      'pcnt': pcnt,
    };
  }

  // Helper methods for parsing
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Extract underlying asset from symbol (BANKNIFTY, NIFTY, etc.)
  static String _extractUnderlying(String symbol) {
    if (symbol.toUpperCase().startsWith('BANKNIFTY')) {
      return 'BANKNIFTY';
    } else if (symbol.toUpperCase().startsWith('NIFTY')) {
      return 'NIFTY';
    }
    return 'UNKNOWN';
  }

  // Extract expiry date from symbol (25JUL, 25AUG, etc.)
  static String _extractExpiry(String symbol) {
    // Pattern: BANKNIFTY25JUL57400PE
    final RegExp regex = RegExp(r'(\d{2}[A-Z]{3})');
    final match = regex.firstMatch(symbol.toUpperCase());
    return match?.group(1) ?? '';
  }

  // Extract strike price from symbol
  static double _extractStrikePrice(String symbol) {
    final sym = symbol.toUpperCase();
    final RegExp regex = RegExp(r'(\d+)(CE|PE)$');
    final match = regex.firstMatch(sym);

    if (match != null) {
      final digits = match.group(1) ?? '';
      if (digits.length > 7) {
        final last5 = digits.substring(digits.length - 5);
        return double.tryParse(last5) ?? 0.0;
      } else {
        return double.tryParse(digits) ?? 0.0;
      }
    }

    return 0.0;
  }

  // Extract option type (CE or PE)
  static String _extractOptionType(String symbol) {
    if (symbol.toUpperCase().endsWith('CE')) {
      return 'CE';
    } else if (symbol.toUpperCase().endsWith('PE')) {
      return 'PE';
    }
    return 'UNKNOWN';
  }

  // Create display name for the option
  static String _createDisplayName(String symbol) {
    final underlying = _extractUnderlying(symbol);
    final expiry = _extractExpiry(symbol);
    final strike = _extractStrikePrice(symbol);
    final type = _extractOptionType(symbol);

    if (underlying != 'UNKNOWN' &&
        expiry.isNotEmpty &&
        strike > 0 &&
        type != 'UNKNOWN') {
      return '$underlying $expiry ${strike.toInt()} $type';
    }
    return symbol;
  }

  // Utility getters
  bool get isCall => optionType == 'CE';
  bool get isPut => optionType == 'PE';
  bool get isBankNifty => underlying == 'BANKNIFTY';
  bool get isNifty => underlying == 'NIFTY' && !isBankNifty;

  // Price change calculation
  double get priceChange => ltp - pc;

  // Formatted percentage change with sign
  String get formattedPercentage {
    final sign = pcnt >= 0 ? '+' : '';
    return '$sign${pcnt.toStringAsFixed(2)}%';
  }
}
