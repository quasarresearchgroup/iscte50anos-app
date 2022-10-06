import 'dart:math';

import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';

class RandomSpotService{



  static Future<void> chooseRandomSpot() async {
    List<Spot> spot = (await DatabaseSpotTable.getAll());
    SharedPrefsService.storeCurrentSpot(spot[Random().nextInt(spot.length)]);
    return;
  }
}