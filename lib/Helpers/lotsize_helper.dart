import 'package:optionxi/Helpers/constants.dart';

int getLotSize({required String? segment, required String? stockName}) {
  // Default lot size for Equity
  int lotSize = 1;

  if ((segment ?? "").toUpperCase() == "FNO") {
    final name = (stockName ?? "").toUpperCase();
    if (name.startsWith("BANKNIFTY")) {
      lotSize = Constants.BANKNIFTY_LOTSIZE;
    } else if (name.startsWith("NIFTY")) {
      lotSize = Constants.NIFTY_LOTSIZE;
    }
  }

  return lotSize;
}
