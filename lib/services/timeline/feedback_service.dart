import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iscte_spots/helper/constants.dart';
import 'package:iscte_spots/models/timeline/feedback_form_result.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class FeedbackService {

  static Future<bool> sendFeedback(
      {required FeedbackFormResult feedbackFormResult}) async {
    LoggerService.instance.debug("Submiting $feedbackFormResult");
    try {
      http.Response response = await http.post(
        Uri.parse('${BackEndConstants.API_ADDRESS}/api/feedback/timeline'),
        headers: <String, String>{
          'content-type': 'application/json',
        },
        body: jsonEncode(feedbackFormResult.toJson()),
      );

      var decodedResponse = await jsonDecode(utf8.decode(response.bodyBytes));
      LoggerService.instance.debug(decodedResponse);
      LoggerService.instance.debug(response.statusCode);
      return response.statusCode == 201;
    } catch (e) {
      LoggerService.instance.error(e);
      return Future.error(e);
    }
  }
}
