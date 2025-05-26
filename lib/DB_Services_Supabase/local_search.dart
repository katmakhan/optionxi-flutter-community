import 'package:optionxi/DataModels/dm_stock_search.dart';
import 'package:optionxi/DataModels/sample_stock_symbols.dart';

Future<List<StockDataSearch>> searchStocksStatic(String query) async {
  try {
    final searchLower = query.toLowerCase();

    final results = totalStocks.entries
        .where((entry) {
          final stockName = entry.value['stock_name']?.toLowerCase() ?? '';
          final fullStockName =
              entry.value['full_stock_name']?.toLowerCase() ?? '';
          return stockName.contains(searchLower) ||
              fullStockName.contains(searchLower);
        })
        .take(15)
        .map((entry) {
          return StockDataSearch(
            stockName: entry.value['stock_name']!,
            fullStockName: entry.value['full_stock_name']!,
          );
        })
        .toList();

    return results;
  } catch (e) {
    print('Error searching stocks locally: $e');
    return [];
  }
}
