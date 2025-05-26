import 'package:flutter/material.dart'; // Add this import for FocusScope
import 'package:get/get.dart';
import 'package:optionxi/DB_Services_Supabase/local_search.dart';
import 'package:optionxi/DataModels/dm_stock_search.dart';
import 'package:optionxi/DB_Services/database_read.dart';
import 'package:optionxi/DB_Services/database_write.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:optionxi/DataModels/dm_watchlist_stock.dart';

class StockSearchControllerAlert extends GetxController {
  final searchQuery = ''.obs;
  final searchResults = <StockDataSearch>[].obs;
  final isLoading = false.obs;
  final showSuggestions = false.obs;
  final favoriteStocks = <String>[].obs; // Store favorite stock symbols

  // Add references to controller and focus node
  TextEditingController? textController;
  FocusNode? focusNode;

  final DatabaseReadService _dbReadService = DatabaseReadService();
  final DatabaseWriteService _dbWriteService = DatabaseWriteService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  // Initialize controller with text controller and focus node
  void initializeControllers(
      TextEditingController controller, FocusNode focus) {
    textController = controller;
    focusNode = focus;
  }

  void setShowSuggestions(bool value) {
    showSuggestions.value = value;
  }

  void clearSearch() {
    // Clear the text controller as well
    if (textController != null) {
      textController!.clear();
    }
    searchQuery.value = '';
    searchResults.clear();
    showSuggestions.value = false;
  }

  void dismissKeyboard() {
    // Unfocus the search field to dismiss keyboard
    if (focusNode != null && focusNode!.hasFocus) {
      focusNode!.unfocus();
    }
  }

  String formatStockName(String stockName) {
    return stockName.split("-")[0].split(":")[1];
  }

  void handleStockSelect(StockDataSearch stock) {
    searchQuery.value = stock.stockName;

    // First dismiss keyboard and clear the search state
    dismissKeyboard();
    clearSearch();

    // Then navigate to the stock page
    // Get.toNamed('/stocks/${formatStockName(stock.stockName.toUpperCase())}');
    // Get.toNamed('/alerts/${stock.stockName.toUpperCase()}');
    Get.offNamedUntil(
      '/alerts/${stock.stockName.toUpperCase().split("-")[0].split(":")[1]}',
      ModalRoute.withName('/home'),
    );
  }

  Future<void> searchStocks(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;
    try {
      final results = await searchStocksStatic(query);

      // Sort results similar to the React implementation
      results.sort((a, b) {
        final searchLower = query.toLowerCase();
        final aStockName = a.stockName.toLowerCase();
        final bStockName = b.stockName.toLowerCase();
        final aFullStockName = a.fullStockName.toLowerCase();
        final bFullStockName = b.fullStockName.toLowerCase();

        // Check for exact matches
        final aExactMatch =
            aStockName == searchLower || aFullStockName == searchLower;
        final bExactMatch =
            bStockName == searchLower || bFullStockName == searchLower;

        if (aExactMatch && !bExactMatch) return -1;
        if (!aExactMatch && bExactMatch) return 1;

        // Check for startsWith matches
        final aStartsWith = aStockName.startsWith(searchLower) ||
            aFullStockName.startsWith(searchLower);
        final bStartsWith = bStockName.startsWith(searchLower) ||
            bFullStockName.startsWith(searchLower);

        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;

        return 0;
      });

      searchResults.value = results;
    } catch (e) {
      print('Error searching stocks: $e');
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Load user's favorite stocks
  Future<void> loadFavorites() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final favorites =
            await _dbReadService.getFavoriteStocks(currentUser.uid);
        favoriteStocks.value =
            favorites.map((stock) => stock.stockName).toList();
      } catch (e) {
        print('Error loading favorites: $e');
      }
    }
  }

  // Check if stock is in favorites
  bool isFavorite(StockDataSearch stock) {
    return favoriteStocks.contains(stock.stockName);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(StockDataSearch stock) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        // Convert StockDataSearch to dm_stock for database operations
        final dmStock = dm_stock(
          stockName: stock.stockName,
          fullStockName: stock.fullStockName,
        );

        // Update local favorites list
        if (isFavorite(stock)) {
          favoriteStocks.remove(stock.stockName);
        } else {
          favoriteStocks.add(stock.stockName);
        }

        await _dbWriteService.toggleFavorite(currentUser.uid, dmStock);
      } catch (e) {
        print('Error toggling favorite: $e');
        Get.snackbar(
          'Error',
          'Failed to update favorites. Please try again.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } else {
      // Handle not logged in state
      Get.snackbar(
        'Error',
        'You must be logged in to add favorites',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Stream user's favorite stocks for real-time updates
  Stream<List<String>> streamFavorites() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _dbReadService
          .streamFavoriteStocks(currentUser.uid)
          .map((stocks) => stocks.map((stock) => stock.stockName).toList());
    }
    return Stream.value([]);
  }

  @override
  void onClose() {
    // Clean up resources
    textController = null;
    focusNode = null;
    super.onClose();
  }
}
