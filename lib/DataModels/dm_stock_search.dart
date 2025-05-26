// For search suggestions
class StockDataSearch {
  final String stockName;
  final String fullStockName;

  StockDataSearch({required this.stockName, required this.fullStockName});

  factory StockDataSearch.fromJson(Map<String, dynamic> json) {
    return StockDataSearch(
      stockName: json['stock_name'] as String,
      fullStockName: json['full_stock_name'] as String,
    );
  }
}
