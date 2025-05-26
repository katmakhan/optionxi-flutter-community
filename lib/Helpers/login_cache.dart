import 'package:get/get.dart';
import 'package:optionxi/Helpers/check_if_firsttime.dart';
import 'package:optionxi/Helpers/get_database.dart';

bool getBrokerLoggedInCache() {
  // Access the Get Database controller
  Database database = Get.find<Database>();
  int updatedOn = database.getUpdatedOn();
  String broker = database.getBrokerName();

  bool loggedInValid = CheckIfFirstTime(updatedOn);
  print("Broker is: " + broker);
  print("Last updated on: " + updatedOn.toString());

  return loggedInValid;
}
