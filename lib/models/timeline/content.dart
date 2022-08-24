import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:logger/logger.dart';

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
    required this.link,
    this.type,
    this.eventId,
  });
  final int? id;
  final String? description;
  final String link;
  final ContentType? type;
  final int? eventId;

  static Logger _logger = Logger();

  @override
  String toString() {
    return 'Content{id: $id, description: $description, link: $link, type: $type, eventId: $eventId}';
  }

  factory Content.fromMap(Map<String, dynamic> json) => Content(
        id: json[DatabaseContentTable.columnId],
        description: json[DatabaseContentTable.columnDescription],
        link: json[DatabaseContentTable.columnLink],
        type: contentTypefromString(json[DatabaseContentTable.columnType]),
        eventId: json[DatabaseContentTable.columnEventId],
      );

  Map<String, dynamic> toMap() {
    return {
      DatabaseContentTable.columnId: id,
      DatabaseContentTable.columnDescription: description,
      DatabaseContentTable.columnLink: link,
      DatabaseContentTable.columnType: type != null ? type!.name : null,
      DatabaseContentTable.columnEventId: eventId,
    };
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
}
