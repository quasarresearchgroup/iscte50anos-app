import 'dart:convert';
import 'dart:io';

import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:logger/logger.dart';

class TimelineContentService {
  static final Logger _logger = Logger();
  static Future<List<Content>> fetchContents({required int eventId}) async {
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final HttpClientRequest request = await client.getUrl(Uri.parse(
          '${BackEndConstants.API_ADDRESS}/api/events/$eventId/contents'));
      request.headers.set('content-type', 'application/json');

      HttpClientResponse response = await request.close();
      var decodedResponse =
          await jsonDecode(await response.transform(utf8.decoder).join());
      _logger.d(decodedResponse);
      // return response.statusCode;
      List<Content> eventsList = [];
      for (var entry in decodedResponse) {
        eventsList.add(Content.fromMap(entry));
      }
      return eventsList;
    } on SocketException {
      rethrow;
    }
  }

  static Future<List<Content>> fetchAllContents() async {
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final HttpClientRequest request = await client
          .getUrl(Uri.parse('${BackEndConstants.API_ADDRESS}/api/content'));
      request.headers.set('content-type', 'application/json');

      HttpClientResponse response = await request.close();
      var decodedResponse =
          await jsonDecode(await response.transform(utf8.decoder).join());
      _logger.d(decodedResponse);
      // return response.statusCode;
      List<Content> eventsList = [];
      for (var entry in decodedResponse) {
        eventsList.add(Content.fromMap(entry));
      }
      return eventsList;
    } on SocketException {
      rethrow;
    }
  }

  static Future<List<Content>> fetchContentsWithinIds(
      {required int lower_id, required int upper_id}) async {
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      final HttpClientRequest request = await client.getUrl(Uri.parse(
          '${BackEndConstants.API_ADDRESS}/api/content/$lower_id-$upper_id'));
      request.headers.set('content-type', 'application/json');

      HttpClientResponse response = await request.close();
      var decodedResponse =
          await jsonDecode(await response.transform(utf8.decoder).join());
      _logger.d(decodedResponse);
      // return response.statusCode;
      List<Content> eventsList = [];
      for (var entry in decodedResponse) {
        eventsList.add(Content.fromMap(entry));
      }
      return eventsList;
    } on SocketException {
      rethrow;
    }
  }
}
