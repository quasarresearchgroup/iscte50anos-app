import 'package:flutter/material.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_topic_table.dart';
import 'package:iscte_spots/models/database/tables/database_topic_table.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/rouded_timeline_icon.dart';
import 'package:iscte_spots/services/timeline/timeline_content_service.dart';
import 'package:logger/logger.dart';

enum EventScope {
  iscte,
  nacional,
  internacional,
}

EventScope? eventScopefromString(String? input) {
  try {
    return EventScope.values.firstWhere(
        (element) => element.name.toLowerCase() == input?.toLowerCase());
  } on StateError {
    return null;
  }
}

class Event {
  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.scope,
    this.visited = false,
  });
  final int id;
  final String title;
  final int date;
  final EventScope? scope;
  bool visited;

  static Logger logger = Logger();

  @override
  String toString() {
    return 'Event{id: $id, title: $title, date: $date, scope: $scope, visited: $visited}';
  }

  String getDateString() {
    DateTime dateDateTime = DateTime.fromMillisecondsSinceEpoch(date);
    return "${dateDateTime.year}-${dateDateTime.month}-${dateDateTime.day}";
  }

  factory Event.fromMap(Map<String, dynamic> json) {
    // Logger().d(json[DatabaseEventTable.columnDate]);
    // Logger().d(DateTime.parse(json[DatabaseEventTable.columnDate])
    //     .millisecondsSinceEpoch);
    return Event(
      id: json[DatabaseEventTable.columnId],
      title: json[DatabaseEventTable.columnTitle],
      date: json[DatabaseEventTable.columnDate] is int
          ? json[DatabaseEventTable.columnDate]
          : DateTime.parse(json[DatabaseEventTable.columnDate])
              .millisecondsSinceEpoch,
      scope: eventScopefromString(json[DatabaseEventTable.columnScope]),
      visited: json[DatabaseEventTable.columnVisited] == null
          ? false
          : json[DatabaseEventTable.columnVisited] == 1
              ? true
              : false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseEventTable.columnId: id,
      DatabaseEventTable.columnTitle: title,
      DatabaseEventTable.columnDate: date,
      DatabaseEventTable.columnScope: scope != null ? scope!.name : null,
      DatabaseEventTable.columnVisited: visited ? 1 : 0,
    };
  }

  Widget? get scopeIcon {
    final Image worldMapImage =
        Image.asset('Resources/Img/TimelineIcons/world-map-819-595.jpg');
    final Image iscte50AnosImage =
        Image.asset('Resources/Img/TimelineIcons/logo_50_anos-819-585.jpg');
    final Image bandeiraPortugalImage =
        Image.asset('Resources/Img/TimelineIcons/pt-819-585.png');
    /*final Image bandeiraPortugalImage =
        Image.asset('icons/flags/png/pt.png', package: 'country_icons');*/

    switch (scope) {
      case EventScope.nacional:
        return RoundedTimelineIcon(child: bandeiraPortugalImage);
      case EventScope.internacional:
        return RoundedTimelineIcon(child: worldMapImage);
      case EventScope.iscte:
        return RoundedTimelineIcon(child: iscte50AnosImage);
      default:
        return null;
    }
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(date);

  Future<List<Topic>> get getTopicsList async {
    List<int> allIdsWithEventId =
        await DatabaseEventTopicTable.getTopicIdsFromEventId(id);
    List<Topic> topicsList =
        await DatabaseTopicTable.getAllWithIds(allIdsWithEventId);
    return topicsList;
  }

  Future<List<Content>> get getContentList async {
    List<int> allIdsWithEventId =
        await DatabaseEventContentTable.getContendIdsFromEventId(id);
    List<Content> contentsList =
        await DatabaseContentTable.getAllWithIds(allIdsWithEventId);
    if (contentsList.isEmpty) {
      contentsList = await TimelineContentService.fetchContents(eventId: id);
    }

    return contentsList;
  }
}
