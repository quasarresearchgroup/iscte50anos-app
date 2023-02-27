import 'dart:math';

import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/services/spotChooser/fetch_all_spots_service.dart';

class RandomSpotService {
  static Future<void> chooseRandomSpot() async {
    List<Spot> spot = (await DatabaseSpotTable.getAll());
    if (spot.isEmpty) {
      await SpotsRequestService.fetchAllSpots();
      spot = (await DatabaseSpotTable.getAll());
    }
    SharedPrefsService.storeCurrentSpot(spot[Random().nextInt(spot.length)]);
    return;
  }
}
