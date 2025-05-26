import 'package:optionxi/DataModels/dm_stock_model.dart';
import 'package:optionxi/DataModels/sample_stock_symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockSupabaseService {
  final supabase = Supabase.instance.client;

  // Normalize symbols by converting -BE to -EQ if needed
  Map<String, String> _normalizeSymbols(List<String> symbols) {
    return {
      for (var s in symbols)
        s.endsWith('-BE') ? s.replaceAll(RegExp(r'-BE$'), '-EQ') : s: s
    };
  }

  // Fetch all live stock data
  Future<List<DataStockModel>> fetchLiveStockData() async {
    try {
      final response = await supabase
          .from('live_5000_stocks')
          .select('*')
          .order('symbol', ascending: true);

      return (response as List)
          .map((item) => DataStockModel.fromJson(item))
          .toList();
    } catch (err) {
      print("Error fetching live stock data: $err");
      return [];
    }
  }

  // Fetch multiple stocks in a single query by symbols list
  Future<List<DataStockModel>> fetchMultipleStocksBySymbols(
      List<String> symbols,
      [Map<String, String>? customFullNames]) async {
    try {
      if (symbols.isEmpty) return [];

      // Normalize symbols
      final symbolMap = _normalizeSymbols(symbols);
      final normalizedSymbols = symbolMap.keys.toList();

      final response = await supabase
          .from('live_5000_stocks')
          .select('*')
          .inFilter('symbol', normalizedSymbols);

      return (response as List).map((item) {
        // Get the normalized symbol from the response
        String normalizedSymbol = item['symbol'] ?? '';
        String originalSymbol = symbolMap[normalizedSymbol] ?? normalizedSymbol;

        // Set the full name from either:
        // 1. Custom full names map (if provided)
        // 2. Static totalStocks map
        // 3. Default to empty string if not found
        if (customFullNames != null &&
            customFullNames.containsKey(originalSymbol)) {
          item['stckname'] = customFullNames[originalSymbol];
        } else if (totalStocks.containsKey(originalSymbol)) {
          item['stckname'] = totalStocks[originalSymbol]!['full_stock_name'];
        }

        return DataStockModel.fromJson(item);
      }).toList();
    } catch (err) {
      print("Error fetching multiple stocks: $err");
      return [];
    }
  }

  // Fetch stock data by stockname
  Future<DataStockModel?> fetchStockDataByName(
      String stockname, String? stockfullname) async {
    try {
      print("fetching stock data: $stockname");

      // Normalize symbol
      final normalizedSymbol = stockname.endsWith('-BE')
          ? stockname.replaceAll(RegExp(r'-BE$'), '-EQ')
          : stockname;

      final response = await supabase
          .from('live_5000_stocks')
          .select('*')
          .eq('symbol', normalizedSymbol)
          .maybeSingle();

      if (response != null) {
        if (stockfullname != null) {
          response["stckname"] = stockfullname;
        }
        return DataStockModel.fromJson(response);
      }
      return null;
    } catch (err) {
      print("Error fetching stock data: $err");
      return null;
    }
  }

  /// Subscribe to real-time updates for multiple stocks
  Stream<List<Map<String, dynamic>>> subscribeToStocks(List<String> symbols,
      [Map<String, String>? customFullNames]) {
    if (symbols.isEmpty) {
      return Stream.value([]);
    }

    // Normalize symbols
    final symbolMap = _normalizeSymbols(symbols);
    final normalizedSymbols = symbolMap.keys.toList();

    return Supabase.instance.client
        .from('live_5000_stocks')
        .stream(primaryKey: ['symbol'])
        .inFilter('symbol', normalizedSymbols)
        .map((event) {
          for (var item in event) {
            String normalizedSymbol = item['symbol'] ?? '';
            String originalSymbol =
                symbolMap[normalizedSymbol] ?? normalizedSymbol;

            // Use original symbol for full name lookup
            if (customFullNames != null &&
                customFullNames.containsKey(originalSymbol)) {
              item['stckname'] = customFullNames[originalSymbol];
            } else if (totalStocks.containsKey(originalSymbol)) {
              item['stckname'] =
                  totalStocks[originalSymbol]!['full_stock_name'];
            }
          }

          return event;
        });
  }
}
