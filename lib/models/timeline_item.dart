import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:logger/logger.dart';

class TimeLineData {
  TimeLineData(
      {required this.data,
      required String date,
      String? scope,
      String? contentType,
      String? contentLink}) {
    switch (scope?.toLowerCase()) {
      case "portugal":
        {
          scopeIcon =
              Image.asset('icons/flags/png/pt.png', package: 'country_icons');
        }
        break;
      case "world":
        {
          scopeIcon = const Icon(FontAwesome.globe);
        }
        break;
      case "iscte":
        {
          scopeIcon = Image.asset('Resources/Img/Logo/logo_50_anos_main.jpg');
        }
        break;
      default:
        {
          scopeIcon = const Icon(FontAwesome.globe);
        }
        break;
    }
    switch (contentType?.toLowerCase()) {
      case "interview":
        {
          contentIcon = const Icon(Icons.mic);
        }
        break;
      case "link":
        {
          contentIcon = const Icon(Icons.link);
        }
        break;
      case "doc":
        {
          contentIcon = const Icon(Icons.document_scanner);
        }
        break;
      default:
        {
          contentIcon = const Icon(Icons.event);
        }
        break;
    }

    if (date.isNotEmpty) {
      List<String> dateSplit = date.split("-");
      if (dateSplit.isNotEmpty) {
        day = int.parse(dateSplit[0]);
        month = int.parse(dateSplit[1]);
        year = int.parse(dateSplit[2]);
      } else {
        year = 0;
        month = 0;
        day = 0;
      }
    } else {
      year = 0;
      month = 0;
      day = 0;
    }
  }

  late final int year;
  late final int month;
  late final int day;
  String? location;
  late final String data;
  late final String contentLink;
  late final Widget? scopeIcon;
  late final Icon? contentIcon;

  static Logger logger = Logger();

  String getDateString() {
    return year.toString() + "-" + month.toString() + "-" + day.toString();
  }
}
