class dm_stock {
  String stockName = '';
  String fullStockName = '';
  double? ltp;
  int? addedAt;

  dm_stock({
    this.stockName = '',
    this.fullStockName = '',
    this.ltp,
    this.addedAt,
  });

  factory dm_stock.fromJson(Map<dynamic, dynamic> json) {
    return dm_stock(
      stockName: json['stockName'] ?? '',
      fullStockName: json['fullStockName'] ?? '',
      ltp: json['ltp'] != null ? double.parse(json['ltp'].toString()) : null,
      addedAt: json['addedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stockName': stockName,
      'fullStockName': fullStockName,
      if (ltp != null) 'ltp': ltp,
      if (addedAt != null) 'addedAt': addedAt,
    };
  }
}
