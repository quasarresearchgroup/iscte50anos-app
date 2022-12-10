import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:logger/logger.dart';

class TimelineEventService {
  static final Logger _logger = Logger();

  static Future<List<Event>> fetchAllEvents() async {
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
    _logger.i("fetched ${eventsList.length} events from server");
    return eventsList;
  }

  static Future<List<Event>> fetchEventsFromYear({required int year}) async {
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
    _logger.i("fetched ${eventsList.length} events from server");
    return eventsList;
  }

  static Future<Event> fetchEvent({required int id}) async {
    http.Response response = await http.get(
        Uri.parse('${BackEndConstants.API_ADDRESS}/api/events/$id'),
        headers: <String, String>{
          'content-type': 'application/json',
        });
    var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
    var event = Event.fromMap(decodedResponse);
    _logger.i("fetched $event from server");
    return event;
  }

  static Future<List<int>> fetchYearsList() async {
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
    _logger.i("fetched ${yearsList.length} years from server");
    return yearsList;
  }
}
