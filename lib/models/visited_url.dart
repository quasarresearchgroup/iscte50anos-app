import 'database/tables/database_page_table.dart';

class VisitedURL {
  final int? id;
  final String content;
  final String? url;
  final int dateTime;

  VisitedURL({
    this.id,
    required this.content,
    required this.dateTime,
    this.url,
  });

  @override
  String toString() {
    return 'VisitedURL{id: $id, content: $content, url: $url, dateTime: $dateTime}';
  }

  String get parsedTime {
    DateTime timeParsed = dateTimeParsed();
    int year = timeParsed.year;
    int month = timeParsed.month;
    int day = timeParsed.day;
    int hour = timeParsed.hour;
    int minute = timeParsed.minute;
    return "$year-$month-$day $hour:$minute";
  }

  factory VisitedURL.fromMap(Map<String, dynamic> json) => VisitedURL(
      id: json[DatabasePageTable.columnId],
      content: json[DatabasePageTable.columnContent],
      url: json[DatabasePageTable.columnUrl],
      dateTime: json[DatabasePageTable.columnDate]);

  Map<String, dynamic> toMap() {
    return {
      DatabasePageTable.columnId: id,
      DatabasePageTable.columnContent: content,
      DatabasePageTable.columnDate: dateTime,
      DatabasePageTable.columnUrl: url
    };
  }

  DateTime dateTimeParsed() {
    return DateTime.fromMillisecondsSinceEpoch(dateTime);
  }
}
