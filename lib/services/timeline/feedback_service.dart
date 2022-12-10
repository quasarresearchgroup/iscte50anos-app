import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/timeline/feedback_form_result.dart';
import 'package:logger/logger.dart';

class FeedbackService {
  static final Logger _logger = Logger();

  static Future<bool> sendFeedback(
      {required FeedbackFormResult feedbackFormResult}) async {
    _logger.d("Submiting $feedbackFormResult");
    try {
      http.Response response = await http.post(
        Uri.parse('${BackEndConstants.API_ADDRESS}/api/feedback/timeline'),
        headers: <String, String>{
          'content-type': 'application/json',
        },
        body: jsonEncode(feedbackFormResult.toJson()),
      );

      var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
      _logger.d(decodedResponse);
      _logger.d(response.statusCode);
      return response.statusCode == 201;
    } catch (e) {
      Logger().e(e);
      return Future.error(e);
    }
  }
}
