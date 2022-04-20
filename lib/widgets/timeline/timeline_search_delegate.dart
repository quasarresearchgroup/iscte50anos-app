import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:iscte_spots/widgets/timeline/timeline_body.dart';
import 'package:logger/logger.dart';

import '../util/loading.dart';

class TimelineSearchDelegate extends SearchDelegate {
  final Logger _logger = Logger();
  List<String> searchResults = [
    'Licenciatura',
    'Doutoramento',
    'Honoris Causa',
    'Reitor',
  ];

  Future<List<Content>>? mapdata;

  TimelineSearchDelegate({required this.mapdata});

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.timesCircle),
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = '';
            }
          },
        )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const FaIcon(FontAwesomeIcons.arrowLeft),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final String queryString = query;
    List<Content> list = [];
    return FutureBuilder(
      future: mapdata,
      builder: (BuildContext context, AsyncSnapshot<List<Content>> snapshot) {
        Widget returningWidget;
        if (snapshot.hasData) {
          list = snapshot.data!.where((element) {
            if (element.description != null) {
              return element.description!
                  .toLowerCase()
                  .contains(queryString.toLowerCase());
            } else {
              return false;
            }
          }).toList();
          _logger.d(list);
          returningWidget = TimeLineBody(mapdata: list);
        } else {
          returningWidget = const LoadingWidget();
        }
        return returningWidget;
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = searchResults.where((searchResult) {
      final String result = searchResult.toLowerCase();
      final String input = query.toLowerCase();

      return result.contains(input);
    }).toList();

    return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final String suggestion = suggestions[index];
          return ListTile(
            title: Text(suggestion),
            onTap: () {
              query = suggestion;
              showResults(context);
            },
          );
        });
  }
}
