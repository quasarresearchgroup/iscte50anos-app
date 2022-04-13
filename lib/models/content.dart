import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:logger/logger.dart';

import '../widgets/timeline/rouded_timeline_icon.dart';
import 'event.dart';

enum ContentType {
  image,
  video,
  web_page,
  social_media,
  doc,
  music,
}

ContentType? contentTypefromString(String? input) {
  try {
    return ContentType.values.firstWhere((element) => element.name == input);
  } on StateError {
    return null;
  }
}

class Content {
  Content({
    this.id,
    this.description,
    this.link,
    this.date,
    this.scope,
    this.type,
    this.eventId,
  });
  final int? id;
  final String? description;
  final String? link;
  final int? date;
  final EventScope? scope;
  final ContentType? type;
  final int? eventId;

  static Logger logger = Logger();

  @override
  String toString() {
    return 'Content{id: $id, description: $description, link: $link, date: $date, scope: $scope, type: $type, eventId: $eventId}';
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

  factory Content.fromMap(Map<String, dynamic> json) => Content(
        id: json[DatabaseContentTable.columnId],
        description: json[DatabaseContentTable.columnDescription],
        link: json[DatabaseContentTable.columnLink],
        date: json[DatabaseContentTable.columnDate],
        scope: eventScopefromString(json[DatabaseContentTable.columnScope]),
        type: contentTypefromString(json[DatabaseContentTable.columnType]),
        eventId: json[DatabaseContentTable.columnEventId],
      );

  Map<String, dynamic> toMap() {
    return {
      DatabaseContentTable.columnId: id,
      DatabaseContentTable.columnDescription: description,
      DatabaseContentTable.columnLink: link,
      DatabaseContentTable.columnDate: date,
      DatabaseContentTable.columnScope: scope != null ? scope!.name : null,
      DatabaseContentTable.columnType: type != null ? type!.name : null,
      DatabaseContentTable.columnEventId: eventId,
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
        return RoundedTimelineIcon(child: bandeiraPortugalImage);
      case EventScope.world:
        return RoundedTimelineIcon(child: worldMapImage);
      case EventScope.iscte:
        return RoundedTimelineIcon(child: iscte50AnosImage);
      default:
        return RoundedTimelineIcon(child: worldMapImage);
    }
  }

  FaIcon get contentIcon {
    switch (type) {
      case ContentType.image:
        return const FaIcon(FontAwesomeIcons.image);
      case ContentType.video:
        return const FaIcon(FontAwesomeIcons.video);
      case ContentType.web_page:
        return const FaIcon(FontAwesomeIcons.link);
      case ContentType.social_media:
        return const FaIcon(FontAwesomeIcons.networkWired);
      case ContentType.doc:
        return const FaIcon(FontAwesomeIcons.book);
      case ContentType.music:
        return const FaIcon(FontAwesomeIcons.music);
      case null:
        return const FaIcon(FontAwesomeIcons.linkSlash);
    }
  }

  int get year {
    int actualDate = date ?? 0;
    DateTime dateDateTime = DateTime.fromMillisecondsSinceEpoch(actualDate);
    return dateDateTime.year;
  }
}
