import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:logger/logger.dart';

enum ContentScope {
  iscte,
  portugal,
  world,
}

ContentScope? ContentScopefromString(String? input) {
  try {
    return ContentScope.values.firstWhere((element) => element.name == input);
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

ContentType? ContentTypefromString(String? input) {
  try {
    return ContentType.values.firstWhere((element) => element.name == input);
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

  @override
  String toString() {
    return 'Content{_title: $_title, date: $date, link: $link, scope: $scope, type: $type}';
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
      title: json[DatabaseContentsTable.columnTitle],
      link: json[DatabaseContentsTable.columnLink],
      date: json[DatabaseContentsTable.columnDate],
      scope: ContentScopefromString(json[DatabaseContentsTable.columnScope]),
      type: ContentTypefromString(json[DatabaseContentsTable.columnType]));

  Map<String, dynamic> toMap() {
    return {
      DatabaseContentsTable.columnTitle: _title,
      DatabaseContentsTable.columnLink: link,
      DatabaseContentsTable.columnDate: date,
      DatabaseContentsTable.columnScope: scope != null ? scope!.name : null,
      DatabaseContentsTable.columnType: type != null ? type!.name : null
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
      case ContentScope.portugal:
        {
          return roundedTimelineIcon(child: bandeiraPortugalImage);
        }
        break;
      case ContentScope.world:
        {
          return roundedTimelineIcon(child: worldMapImage);
          //return const FaIcon(FontAwesomeIcons.globe);
        }
        break;
      case ContentScope.iscte:
        {
          return roundedTimelineIcon(child: iscte50AnosImage);
        }
        break;
      default:
        {
          return roundedTimelineIcon(child: worldMapImage);
          //return const FaIcon(FontAwesomeIcons.globe);
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

class roundedTimelineIcon extends StatelessWidget {
  roundedTimelineIcon({
    Key? key,
    required this.child,
  }) : super(key: key);

  final double borderRadious = 10;
  final double padding = 10;
  final Image child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadious), child: child),
    );
  }
}
