import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class TimelineEventService {
  static Future<List<Event>> fetchAllEvents() async {
    try {
      http.Response response = await http.get(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/events'),
          headers: <String, String>{
            'content-type': 'application/json',
          });

      var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
      List<Event> eventsList = [];
      for (var entry in decodedResponse) {
        eventsList.add(Event.fromMap(entry));
      }
      LoggerService.instance
          .info("fetched ${eventsList.length} events from server");
      return eventsList;
    } catch (e) {LoggerService.instance.error(e);
      return Future.error(e);
    }
  }

  static Future<List<Event>> fetchEventsFromYear({required int year}) async {
    try {
      http.Response response = await http.get(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/events/year/$year'),
          headers: <String, String>{
            'content-type': 'application/json',
          });
      var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
      List<Event> eventsList = [];
      for (var entry in decodedResponse) {
        eventsList.add(Event.fromMap(entry));
      }
      LoggerService.instance
          .info("fetched ${eventsList.length} events from server");
      return eventsList;
    } catch (e) {LoggerService.instance.error(e);
      return Future.error(e);
    }
  }

  static Future<Event> fetchEvent({required int id}) async {
    try {
      http.Response response = await http.get(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/events/$id'),
          headers: <String, String>{
            'content-type': 'application/json',
          });
      var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
      var event = Event.fromMap(decodedResponse);
      LoggerService.instance.info("fetched $event from server");
      return event;
    } catch (e) {LoggerService.instance.error(e);
      return Future.error(e);
    }
  }

  static Future<List<int>> fetchYearsList() async {
    try {
      http.Response response = await http.get(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/events/years'),
          headers: <String, String>{
            'content-type': 'application/json',
          });
      var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
      List<int> yearsList = [];
      for (var entry in decodedResponse) {
        yearsList.add(int.parse(entry.toString().split("-")[0]));
      }
      LoggerService.instance
          .info("fetched ${yearsList.length} years from server");
      return yearsList;
    } catch (e) {LoggerService.instance.error(e);
      return Future.error(e);
    }
  }
}
