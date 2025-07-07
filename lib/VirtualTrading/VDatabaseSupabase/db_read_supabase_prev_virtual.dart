import 'package:optionxi/DataModels/dm_stock_model.dart';
import 'package:optionxi/VirtualTrading/VDataModel/v_prev_fnodata.dart';
import 'package:optionxi/DataModels/sample_stock_symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VirtualSupabaseService {
  final supabase = Supabase.instance.client;

  // ========== STOCK DATA METHODS ==========

  // Fetch Nifty 50 stocks specifically and sort by symbol name
  Future<List<DataStockModel>> fetchNifty50Stocks() async {
    try {
      final response = await supabase.from('prev_nifty50_stocks').select('*');

      List<DataStockModel> stocks = (response as List).map((item) {
        String symbol = item['symbol'] ?? '';

        // Set the full name from totalStocks map
        if (totalStocks.containsKey(symbol)) {
          item['stckname'] = totalStocks[symbol]!['full_stock_name'];
        }

        return DataStockModel.fromJson(item);
      }).toList();

      // Sort by symbol name alphabetically
      stocks.sort((a, b) => a.symbol.compareTo(b.symbol));

      return stocks;
    } catch (err) {
      print("Error fetching Nifty 50 stocks: $err");
      return [];
    }
  }

  /// Subscribe to Nifty 50 real-time updates
  Stream<List<Map<String, dynamic>>> subscribeToNifty50Stocks() {
    try {
      return Supabase.instance.client
          .from('prev_nifty50_stocks')
          .stream(primaryKey: ['symbol']).map((event) {
        for (var item in event) {
          String symbol = item['symbol'] ?? '';

          // Set the full name from totalStocks map
          if (totalStocks.containsKey(symbol)) {
            item['stckname'] = totalStocks[symbol]!['full_stock_name'];
          }
        }
        return event;
      });
    } catch (err) {
      print("Error setting up Nifty 50 subscription: $err");
      return Stream.value([]);
    }
  }

  // ========== FNO DATA METHODS ==========

  // Fetch all FNO data from prev_fno_bankandnifty
  Future<List<DataFNOModel>> fetchFNOData() async {
    try {
      final response = await supabase
          .from('prev_fno_bankandnifty')
          .select('*')
          .order('symbol', ascending: true);

      return (response as List)
          .map((item) => DataFNOModel.fromJson(item))
          .toList();
    } catch (err) {
      print("Error fetching FNO data: $err");
      return [];
    }
  }

  /// Subscribe to real-time FNO updates
  /// Subscribe to real-time FNO updates
  Stream<List<Map<String, dynamic>>> subscribeToFNOData() {
    try {
      return supabase
          .from('prev_fno_bankandnifty')
          .stream(primaryKey: ['symbol']).map((event) {
        for (var item in event) {
          String symbol = item['symbol'] ?? '';

          // You could also add logic to categorize or enrich the data here
          bool isBankNifty = symbol.toUpperCase().startsWith('BANKNIFTY');

          // Add type indicator if useful
          item['option_type'] = isBankNifty ? 'BANKNIFTY' : 'NIFTY';
        }
        return event;
      });
    } catch (err) {
      print("Error setting up FNO subscription: $err");
      return Stream.value([]);
    }
  }
}
