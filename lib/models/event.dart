import 'package:flutter/material.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:logger/logger.dart';

import '../widgets/timeline/rouded_timeline_icon.dart';

enum EventScope {
  iscte,
  portugal,
  world,
}

EventScope? EventScopefromString(String? input) {
  try {
    return EventScope.values.firstWhere((element) => element.name == input);
  } on StateError {
    return null;
  }
}

class Event {
  Event({
    this.id,
    this.title,
    this.date,
    this.scope,
  });
  final int? id;
  final String? title;
  final int? date;
  final EventScope? scope;

  static Logger logger = Logger();

  @override
  String toString() {
    return 'Event{id: $id, title: $title, date: $date, scope: $scope}';
  }

  String getDateString() {
    int actualDate = date ?? 0;
    DateTime dateDateTime = DateTime.fromMillisecondsSinceEpoch(actualDate);
    return dateDateTime.year.toString() +
        "-" +
        dateDateTime.month.toString() +
        "-" +
        dateDateTime.day.toString();
  }

  factory Event.fromMap(Map<String, dynamic> json) => Event(
        id: json[DatabaseContentTable.columnId],
        title: json[DatabaseContentTable.columnDescription],
        date: json[DatabaseContentTable.columnDate],
        scope: EventScopefromString(json[DatabaseContentTable.columnScope]),
      );

  Map<String, dynamic> toMap() {
    return {
      DatabaseContentTable.columnId: id,
      DatabaseContentTable.columnDescription: title,
      DatabaseContentTable.columnDate: date,
      DatabaseContentTable.columnScope: scope != null ? scope!.name : null,
    };
  }

  Widget get scopeIcon {
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
        return roundedTimelineIcon(child: bandeiraPortugalImage);
      case EventScope.world:
        return roundedTimelineIcon(child: worldMapImage);
      case EventScope.iscte:
        return roundedTimelineIcon(child: iscte50AnosImage);
      default:
        return roundedTimelineIcon(child: worldMapImage);
    }
  }

  int get year {
    int actualDate = date ?? 0;
    DateTime dateDateTime = DateTime.fromMillisecondsSinceEpoch(actualDate);
    return dateDateTime.year;
  }
}
