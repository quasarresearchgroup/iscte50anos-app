import 'dart:convert';
import 'dart:io';

import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:logger/logger.dart';

class TimelineEventService {
  static final Logger _logger = Logger();

  static Future<List<Event>> fetchAllEvents() async {
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final HttpClientRequest request = await client
          .getUrl(Uri.parse('${BackEndConstants.API_ADDRESS}/api/events'));
      request.headers.set('content-type', 'application/json');

      HttpClientResponse response = await request.close();
      var decodedResponse =
          await jsonDecode(await response.transform(utf8.decoder).join());
      // _logger.d(decodedResponse);
      // return response.statusCode;
      List<Event> eventsList = [];
      for (var entry in decodedResponse) {
        eventsList.add(Event.fromMap(entry));
      }
      return eventsList;
    } on SocketException {
      rethrow;
    }
  }

  static Future<List<Event>> fetchEvents(
      {required int year, required int multiplier}) async {
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final HttpClientRequest request = await client.getUrl(Uri.parse(
          '${BackEndConstants.API_ADDRESS}/api/events/year/$year-$multiplier'));
      request.headers.set('content-type', 'application/json');

      HttpClientResponse response = await request.close();
      var decodedResponse =
          await jsonDecode(await response.transform(utf8.decoder).join());
      // _logger.d(decodedResponse);
      // return response.statusCode;
      List<Event> eventsList = [];
      for (var entry in decodedResponse) {
        eventsList.add(Event.fromMap(entry));
      }
      return eventsList;
    } on SocketException {
      rethrow;
    }
  }
}
