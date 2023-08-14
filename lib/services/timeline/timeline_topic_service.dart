import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class TimelineTopicService {

  static Future<List<Event>> fetchEvents(
      {Iterable<int> topicIds = const [],
      Iterable<String> scopes = const []}) async {
    LoggerService.instance.debug("$topicIds; $scopes");

    try {
      String string = topicIds.fold("", (previousValue, element) {
        if (previousValue.isEmpty) {
          return "topic=$element";
        } else {
          return "$previousValue&topic=$element";
        }
      });
      string = string +
          scopes.fold(topicIds.isEmpty ? "" : "&",
              (previousValue, String element) {
            return "$previousValue&scope=$element";
          });
      LoggerService.instance
          .debug('${BackEndConstants.API_ADDRESS}/api/events/?$string');
      http.Response response = await http.get(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/events/?$string'),
          headers: <String, String>{
            'content-type': 'application/json',
          });

      var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));

      List<Event> eventsList = [];
      for (var entry in decodedResponse) {
        eventsList.add(Event.fromMap(entry));
      }
      LoggerService.instance
          .info("fetched ${eventsList.length} events with topics: $topicIds");
      return eventsList;
    } catch (e) {
      LoggerService.instance.error(e);
      return Future.error(e);
    }
  }

  static Future<List<Topic>> fetchTopics({required int eventId}) async {
    try {
      http.Response response = await http.get(
          Uri.parse(
              '${BackEndConstants.API_ADDRESS}/api/events/$eventId/topics'),
          headers: <String, String>{
            'content-type': 'application/json',
          });

      var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
      //_logger.d(decodedResponse);
      // return response.statusCode;
      List<Topic> topicsList = [];
      for (var entry in decodedResponse) {
        topicsList.add(Topic.fromJson(entry));
      }
      LoggerService.instance.info("fetched topics from event: $eventId");
      return topicsList;
    } catch (e) {
      LoggerService.instance.error(e);
      return Future.error(e);
    }
  }

  static Future<List<Topic>> fetchAllTopics() async {
    try {
      http.Response response = await http.get(
          Uri.parse('${BackEndConstants.API_ADDRESS}/api/topics'),
          headers: <String, String>{
            'content-type': 'application/json',
          });

      var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
      //_logger.d(decodedResponse);
      // return response.statusCode;
      List<Topic> topicsList = [];
      for (var entry in decodedResponse) {
        topicsList.add(Topic.fromJson(entry));
      }
      LoggerService.instance.info("fetched all topics");
      return topicsList;
    } catch (e) {
      LoggerService.instance.error(e);
      return Future.error(e);
    }
  }
}
