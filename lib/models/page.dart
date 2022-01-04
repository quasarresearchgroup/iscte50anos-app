import 'package:ISCTE_50_Anos/helper/database_helper.dart';

class VisitedPage {
  final int? id;
  final String content;
  final int dateTime;

  VisitedPage({this.id, required this.content, required this.dateTime});

  factory VisitedPage.fromMap(Map<String, dynamic> json) => VisitedPage(
      id: json[DatabaseHelper.columnId],
      content: json[DatabaseHelper.columnContent],
      dateTime: json[DatabaseHelper.columnDate]);

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnContent: content,
      DatabaseHelper.columnDate: dateTime
    };
  }

  DateTime dateTimeParsed() {
    return DateTime.fromMillisecondsSinceEpoch(dateTime);
  }
}
