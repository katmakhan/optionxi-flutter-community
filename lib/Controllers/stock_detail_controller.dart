// file: lib/controllers/stock_controller.dart

import 'package:get/get.dart';
import 'package:optionxi/DB_Services_Supabase/database_read_supabase.dart';
import 'package:optionxi/DataModels/dm_stock_model.dart';

class StockController extends GetxController {
  final StockSupabaseService _stockService = StockSupabaseService();

  // Observable variables
  final Rx<DataStockModel?> stock = Rx<DataStockModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString timeframe = '1D'.obs;
  final RxBool showVolume = true.obs;

  // List of available timeframes
  final List<String> timeframes = ['1H', '1D', '1W', '1M', '3M', '1Y', 'ALL'];

  // Method to fetch stock data
  Future<void> fetchStockData(String stockname) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final stockData =
          await _stockService.fetchStockDataByName(stockname, null);

      if (stockData != null) {
        stock.value = stockData;
      } else {
        hasError.value = true;
        errorMessage.value = 'Stock data not found';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load stock data: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Method to toggle volume display
  void toggleVolume() {
    showVolume.value = !showVolume.value;
  }

  // Method to change timeframe
  void changeTimeframe(String newTimeframe) {
    if (timeframes.contains(newTimeframe)) {
      timeframe.value = newTimeframe;
      // Here you could refetch data with the new timeframe if needed
    }
  }
}
