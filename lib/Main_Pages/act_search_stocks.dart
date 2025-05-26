import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:optionxi/Controllers/stock_search_controller.dart';

class StockSearchPage extends StatefulWidget {
  final bool fromwatchlist;
  const StockSearchPage(this.fromwatchlist, {Key? key}) : super(key: key);

  @override
  _StockSearchPageState createState() => _StockSearchPageState();
}

class _StockSearchPageState extends State<StockSearchPage> {
  final StockSearchController controller = Get.put(StockSearchController());
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Set up focus listener once
    focusNode.addListener(() {
      controller.setShowSuggestions(focusNode.hasFocus);
    });

    // Initialize text controller and focus node in controller
    controller.initializeControllers(textController, focusNode);

    // Load favorites initially
    controller.loadFavorites();
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    focusNode.requestFocus();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(context, isDarkMode),
            _buildSuggestionsList(context, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: TextField(
        controller: textController,
        focusNode: focusNode,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: "Search your stocks eg: RELIANCE, ABAN...",
          hintStyle: TextStyle(
            color: Theme.of(context).textTheme.titleSmall?.color,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (value) {
          controller.searchQuery.value = value;
          controller.searchStocks(value);
        },
      ),
    );
  }

  Widget _buildSuggestionsList(BuildContext context, bool isDarkMode) {
    return Obx(() {
      if (!controller.showSuggestions.value) {
        return const SizedBox.shrink();
      }

      return Expanded(
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.searchResults.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Search stocks like RELIANCE, ABAN, HDFC...',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final stock = controller.searchResults[index];
                        return InkWell(
                          onTap: () => controller.handleStockSelect(
                              stock, widget.fromwatchlist),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border:
                                  index < controller.searchResults.length - 1
                                      ? Border(
                                          bottom: BorderSide(
                                            color: isDarkMode
                                                ? Colors.grey[800]!
                                                : Colors.grey[200]!,
                                            width: 0.5,
                                          ),
                                        )
                                      : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stock.fullStockName,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        controller
                                            .formatStockName(stock.stockName),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Stock',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Obx(() => IconButton(
                                          onPressed: () =>
                                              controller.toggleFavorite(stock),
                                          icon: Icon(
                                            controller.isFavorite(stock)
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: controller.isFavorite(stock)
                                                ? Colors.yellow
                                                : isDarkMode
                                                    ? Colors.grey[400]
                                                    : Colors.grey[500],
                                            size: 20,
                                          ),
                                          splashRadius: 20,
                                          tooltip: 'Add to favorites',
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      );
    });
  }
}
