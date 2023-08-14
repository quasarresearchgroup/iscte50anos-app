import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ContentType {
  doc,
  web_page,
  social_media,
  video,
  music,
  image,
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
    required this.id,
    this.title,
    required this.link,
    this.type,
    this.eventId,
    this.validated,
  });

  final int id;
  final String? title;
  final String link;
  final ContentType? type;
  final int? eventId;
  final bool? validated;


  @override
  String toString() {
    return 'Content{id: $id, title: $title, link: $link, type: $type, eventId: $eventId, validated: $validated}';
  }

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        id: json["id"],
        title: json["title"],
        link: json["link"],
        type: contentTypefromString(json["type"]),
        eventId: json["event_id"],
        validated: json["validated"],
      );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "link": link,
      "type": type != null ? type!.name : null,
      "event_id": eventId,
      "validated": validated,
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
