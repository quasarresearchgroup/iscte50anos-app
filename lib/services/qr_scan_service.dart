import 'dart:io';

import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:iscte_spots/models/database/tables/database_page_table.dart';
import 'package:iscte_spots/models/visited_url.dart';
import 'package:iscte_spots/pages/home/scanPage/qr_scan_page.dart';
import 'package:logger/logger.dart';
import 'package:synchronized/synchronized.dart';

class QRScanService {
  static final Logger _logger = Logger();

  static Future<String> extractData(final String url) async {
    _logger.d("url:$url");
    try {
      final response = await http.Client().get(Uri.parse(url));
      //Status Code 200 means response has been received successfully
      if (response.statusCode == 200) {
        var lock = Lock();
        int millisecondsSinceEpoch2 = DateTime.now().millisecondsSinceEpoch;
        var title = parser
            .parse(response.body)
            .getElementsByClassName(QRScanPage.titleHtmlTag);
        String name = title.map((e) => e.text).join("");

        await DatabasePageTable.add(VisitedURL(
            content: name, dateTime: millisecondsSinceEpoch2, url: url));
        _logger.d("-----------------title-----------------------\n" +
            name +
            "\n" +
            millisecondsSinceEpoch2.toString());
        return name;
      } else {
        return 'ERROR: ${response.statusCode}.';
      }
    } on SocketException {
      rethrow;
    } catch (e) {
      _logger.e(e);
      return 'ERROR: ${e.toString()}.';
    }
  }
}
