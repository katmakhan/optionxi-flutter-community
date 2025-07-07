import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- DATA MODELS ---
// NOTE: It's best practice to have these in separate files (e.g., 'models/holding_model.dart')
class Holding {
  final String symbol;
  final String segment;
  final int quantity;
  final double averagePrice;
  final DateTime updatedAt;

  Holding({
    required this.symbol,
    required this.segment,
    required this.quantity,
    required this.averagePrice,
    required this.updatedAt,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      symbol: json['symbol'] ?? 'N/A',
      segment: json['segment'] ?? 'N/A',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      averagePrice: (json['average_price'] as num?)?.toDouble() ?? 0.0,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class TradeHistory {
  final String symbol;
  final String segment;
  final String transactionType;
  final double price;
  final double quantity;
  final double profitLoss;
  final bool isShortSell;
  final DateTime executionTime;

  TradeHistory({
    required this.symbol,
    required this.segment,
    required this.transactionType,
    required this.price,
    required this.quantity,
    required this.profitLoss,
    required this.isShortSell,
    required this.executionTime,
  });

  factory TradeHistory.fromJson(Map<String, dynamic> json) {
    return TradeHistory(
      symbol: json['symbol'] ?? 'N/A',
      segment: json['segment'] ?? 'N/A',
      transactionType: json['transaction_type'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      profitLoss: (json['profit_loss'] as num?)?.toDouble() ?? 0.0,
      isShortSell: (json['is_short_sell'] as bool?) ?? false,
      executionTime: json['execution_time'] != null
          ? DateTime.parse(json['execution_time'])
          : DateTime.now(),
    );
  }
}

// --- SERVICE CLASS ---
class PortfolioService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- FETCH METHODS ---
  Future<double> fetchBalance(String suid) async {
    try {
      final response = await _supabase
          .from('prev_balance')
          .select('balance')
          .eq('suid', suid)
          .maybeSingle();
      if (response == null || response['balance'] == null) {
        return 0.0;
      }
      return (response['balance'] as num).toDouble();
    } catch (e) {
      print('Error fetching balance: $e');
      return 0.0;
    }
  }

  Future<List<Holding>> fetchHoldings(String suid) async {
    try {
      final response =
          await _supabase.from('prev_user_holdings').select().eq('suid', suid);
      return (response as List).map((e) => Holding.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching holdings: $e');
      return [];
    }
  }

  Future<List<Holding>> fetchShortPositions(String suid) async {
    try {
      final response = await _supabase
          .from('prev_short_positions')
          .select()
          .eq('suid', suid);
      return (response as List).map((e) => Holding.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching short positions: $e');
      return [];
    }
  }

  Future<List<TradeHistory>> fetchTradeHistory(String suid) async {
    try {
      final response =
          await _supabase.from('prev_trade_history').select().eq('suid', suid);
      return (response as List).map((e) => TradeHistory.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching trade history: $e');
      return [];
    }
  }

  // --- SUBSCRIPTION (REALTIME) METHODS ---
  // Note: These now filter on the client-side to prevent the PostgrestException.
  // For large tables, a more optimized approach using database functions (RPC) or channels is recommended.

  Stream<double> subscribeToBalance(String suid) {
    return _supabase
        .from('prev_balance')
        .stream(primaryKey: ['id'])
        .eq('suid', suid) // Server-side filtering
        .map((payload) {
          if (payload.isEmpty || payload.first['balance'] == null) {
            return 0.0;
          }
          return (payload.first['balance'] as num).toDouble();
        });
  }

  Stream<List<Holding>> subscribeToHoldings(String suid) {
    return _supabase
        .from('prev_user_holdings')
        .stream(primaryKey: ['id'])
        .eq('suid', suid) // Server-side filtering
        .map((payload) => payload.map((e) => Holding.fromJson(e)).toList());
  }

  Stream<List<Holding>> subscribeToShortPositions(String suid) {
    return _supabase
        .from('prev_short_positions')
        .stream(primaryKey: ['id'])
        .eq('suid', suid) // Apply server-side filter
        .map((payload) => payload.map((e) => Holding.fromJson(e)).toList());
  }

  Stream<List<TradeHistory>> subscribeToTradeHistory(String suid) {
    return _supabase
        .from('prev_trade_history')
        .stream(primaryKey: ['id'])
        .eq('suid', suid) // Apply server-side filter
        .map(
            (payload) => payload.map((e) => TradeHistory.fromJson(e)).toList());
  }

  Stream<List<Map<String, dynamic>>> subscribeToLiveNifty50() {
    return _supabase.from('prev_nifty50_stocks').stream(primaryKey: ['symbol']);
  }

  Stream<List<Map<String, dynamic>>> subscribeToLiveFNO() {
    return _supabase
        .from('prev_fno_bankandnifty')
        .stream(primaryKey: ['symbol']);
  }
}
