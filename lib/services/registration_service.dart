import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class RegistrationService {
  static const String AfiliationsFile = 'Resources/Afiliacoes&Inscritos.csv';
  static final Logger _logger = Logger();

  static Future<Map<String, List<String>>> getSchoolAffiliations() async {
    await Future.delayed(Duration(seconds: 1));

    try {
      final String file = await rootBundle.loadString(AfiliationsFile);

      final Map<String, List<String>> result = {};

      result["-"] = <String>["-"];
      file.split("\n").forEach((line) {
        List<String> lineSplit = line.split(",");
        String district = lineSplit[1];
        String school = lineSplit[0];
        if (result[district] == null) {
          result[district] = <String>["-", school];
        } else {
          result[district]!.add(school);
        }
      });
      return result;
    } catch (e) {
      _logger.e(e);
      rethrow;
    }
  }
}
