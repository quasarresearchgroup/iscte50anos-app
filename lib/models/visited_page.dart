import 'package:ISCTE_50_Anos/helper/database_helper.dart';

class VisitedPage {
  final int? id;
  final String content;
  final String? url;
  final int dateTime;

  VisitedPage({
    this.id,
    required this.content,
    required this.dateTime,
    this.url,
  });

  String get parsed_time {
    DateTime timeParsed = dateTimeParsed();
    int year = timeParsed.year;
    int month = timeParsed.month;
    int day = timeParsed.day;
    int hour = timeParsed.hour;
    int minute = timeParsed.minute;
    return "$year-$month-$day $hour:$minute";
  }

  factory VisitedPage.fromMap(Map<String, dynamic> json) => VisitedPage(
      id: json[DatabaseHelper.columnId],
      content: json[DatabaseHelper.columnContent],
      url: json[DatabaseHelper.columnUrl],
      dateTime: json[DatabaseHelper.columnDate]);

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnContent: content,
      DatabaseHelper.columnDate: dateTime,
      DatabaseHelper.columnUrl: url
    };
  }

  DateTime dateTimeParsed() {
    return DateTime.fromMillisecondsSinceEpoch(dateTime);
  }
}
