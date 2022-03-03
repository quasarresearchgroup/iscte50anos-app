import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:logger/logger.dart';

enum ContentScope {
  iscte,
  portugal,
  world,
}

ContentScope? ContentScopefromString(String input) {
  try {
    return ContentScope.values
        .firstWhere((element) => element.toString() == input);
  } on StateError {
    return null;
  }
}

enum ContentType {
  image,
  video,
  web_page,
  social_media,
  doc,
  music,
}

ContentType? ContentTypefromString(String input) {
  try {
    return ContentType.values
        .firstWhere((element) => element.toString() == input);
  } on StateError {
    return null;
  }
}

class Content {
  Content({
    String? title,
    this.link,
    this.date,
    this.scope,
    this.type,
  }) {
    _title = title;
  }

  late final String? _title;
  final int? date;
  final String? link;
  final ContentScope? scope;
  final ContentType? type;

  static Logger logger = Logger();

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
      title: json[DatabaseContentsTable.columnTitle],
      link: json[DatabaseContentsTable.columnLink],
      date: json[DatabaseContentsTable.columnDate],
      scope: json[DatabaseContentsTable.columnScope],
      type: json[DatabaseContentsTable.columnType]);

  Map<String, dynamic> toMap() {
    return {
      DatabaseContentsTable.columnTitle: _title,
      DatabaseContentsTable.columnLink: link,
      DatabaseContentsTable.columnDate: date,
      DatabaseContentsTable.columnScope: scope,
      DatabaseContentsTable.columnType: type
    };
  }

  Widget get scopeIcon {
    switch (scope) {
      case ContentScope.portugal:
        {
          return Image.asset('icons/flags/png/pt.png',
              package: 'country_icons');
        }
        break;
      case ContentScope.world:
        {
          return const FaIcon(FontAwesomeIcons.globe);
        }
        break;
      case ContentScope.iscte:
        {
          return Image.asset('Resources/Img/Logo/logo_50_anos_main.jpg');
        }
        break;
      default:
        {
          return const FaIcon(FontAwesomeIcons.globe);
        }
        break;
    }
  }

  FaIcon get contentIcon {
    switch (type) {
      case ContentType.image:
        return const FaIcon(FontAwesomeIcons.image);
        break;
      case ContentType.video:
        return const FaIcon(FontAwesomeIcons.video);
        break;
      case ContentType.web_page:
        return const FaIcon(FontAwesomeIcons.link);
        break;
      case ContentType.social_media:
        return const FaIcon(FontAwesomeIcons.networkWired);
        break;
      case ContentType.doc:
        return const FaIcon(FontAwesomeIcons.book);
        break;
      case ContentType.music:
        return const FaIcon(FontAwesomeIcons.music);
        break;
      case null:
        return const FaIcon(FontAwesomeIcons.unlink);
    }
  }

  int get year {
    int actualDate = date ?? 0;
    DateTime dateDateTime = DateTime.fromMillisecondsSinceEpoch(actualDate);
    return dateDateTime.year;
  }

  String get title {
    return _title ?? "";
  }
}
