import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/rouded_timeline_icon.dart';
import 'package:iscte_spots/services/timeline/timeline_content_service.dart';
import 'package:iscte_spots/services/timeline/timeline_topic_service.dart';
import 'package:logger/logger.dart';

enum EventScope {
  iscte,
  portugal,
  world,
}

EventScope? eventScopefromString(String? input) {
  try {
    return EventScope.values.firstWhere(
        (element) => element.name.toLowerCase() == input?.toLowerCase());
  } on StateError {
    Logger().e("Error on :$input");
    return null;
  }
}

class Event {
  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.scope,
//    required this.topics,
    required this.contentCount,
    this.visited = false,
  });

  final int id;
  final String title;
  final int date;
  final EventScope? scope;
  bool visited;
  int contentCount;
  //final List<Topic> topics;

  static Logger logger = Logger();

  @override
  String toString() {
    // return 'Event{id: $id, title: $title, date: $date, scope: $scope, visited: $visited}';
    return 'Event{id: $id, title: $title, date: $date, scope: $scope, visited: $visited,contentCount: $contentCount}';
  }

  String getDateString() {
    DateTime dateDateTime = DateTime.fromMillisecondsSinceEpoch(date);
    return "${dateDateTime.year}-${dateDateTime.month}-${dateDateTime.day}";
  }

  factory Event.fromMap(Map<String, dynamic> json) {
    // Logger().d(json[DatabaseEventTable.columnDate]);
    // Logger().d(DateTime.parse(json[DatabaseEventTable.columnDate])
    //     .millisecondsSinceEpoch);
    /*
    List<Topic> topics = [];
    for (dynamic entry in json["topics"]) {
      topics.add(Topic.fromMap(entry));
    }*/
    return Event(
      id: json["id"],
      title: json["title"],
      date: json["date"] is int
          ? json["date"]
          : DateTime.parse(json["date"]).millisecondsSinceEpoch,
      scope: eventScopefromString(json["scope"]),
      visited: json["visited"] == null
          ? false
          : json["visited"] == 1
              ? true
              : false,
      contentCount: json["num_content"],
      //topics: topics,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "date": date,
      "scope": scope != null ? scope!.name : null,
      "visited": visited ? 1 : 0,
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
      case EventScope.portugal:
        return RoundedTimelineIcon(child: bandeiraPortugalImage);
      case EventScope.world:
        return RoundedTimelineIcon(child: worldMapImage);
      case EventScope.iscte:
        return RoundedTimelineIcon(child: iscte50AnosImage);
      default:
        return null;
    }
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(date);

  Future<List<Topic>> get getTopicsList async {
    return await TimelineTopicService.fetchTopics(eventId: id);
    /*  List<int> allIdsWithEventId =
        await DatabaseEventTopicTable.getTopicIdsFromEventId(id);
    List<Topic> topicsList =
        await DatabaseTopicTable.getAllWithIds(allIdsWithEventId);
    return topicsList;*/
  }

  Future<List<Content>> get getContentList async {
    return await TimelineContentService.fetchContents(eventId: id);
  }
}
