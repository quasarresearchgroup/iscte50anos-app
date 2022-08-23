/*
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/pages/timeline/timeline_filter_page.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class TimelineSearchDelegate extends SearchDelegate {
  final Logger _logger = Logger();
  List<String> searchResults = [
    'Licenciatura',
    'Doutoramento',
    'Honoris Causa',
    'Reitor',
  ];

  Future<List<Event>>? mapdata;

  TimelineSearchDelegate({required this.mapdata});

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = '';
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_alt),
          onPressed: () {
            _navigateToFilterPage(context);
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
    List<Event> list = [];
    return FutureBuilder(
      future: mapdata,
      builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
        Widget returningWidget;
        if (snapshot.hasData) {
          list = snapshot.data!.where((element) {
            if (element.title != null) {
              return element.title!
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

  void _navigateToFilterPage(BuildContext context) {
    Navigator.of(context).pushNamed(TimelineFilterPage.pageRoute);
  }
}
*/
