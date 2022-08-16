import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/database/tables/database_event_table.dart';
import 'package:iscte_spots/models/database/tables/database_topic_table.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class TimelineFilterPage extends StatefulWidget {
  TimelineFilterPage({Key? key}) : super(key: key);
  static const String pageRoute = "${TimelinePage.pageRoute}/filter";

  @override
  State<TimelineFilterPage> createState() => _TimelineFilterPageState();
}

class _TimelineFilterPageState extends State<TimelineFilterPage> {
  Topic? selectedTopic;
  List<Topic> selectedTopics = [];

  late final Future<List<Topic>> availableTopics;
  late final TextEditingController searchBarController;

  final Logger _logger = Logger();

  @override
  void initState() {
    searchBarController = TextEditingController();
    super.initState();
    availableTopics = DatabaseTopicTable.getAll();
  }

  @override
  void dispose() {
    super.dispose();
    searchBarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildSearchBar(context, selectedTopics.isEmpty),
      ),
      body: buildBody(context, selectedTopics.isEmpty),
    );
  }

  Padding buildBody(BuildContext context, bool isEmptySelectedTopics) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...(isEmptySelectedTopics)
              ? []
              : [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(AppLocalizations.of(context)!
                            .timelineSelectedTopics)),
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    direction: Axis.horizontal,
                    children: selectedTopics
                        .map((e) => Card(
                              color: IscteTheme.iscteColor,
                              shape: const StadiumBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  e.title ?? "",
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const Divider(height: 20, thickness: 2),
                ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    AppLocalizations.of(context)!.timelineAvailableTopics)),
          ),
          Expanded(
            child: buildTopicsCheckBoxList(),
          ),
          const Divider(height: 20, thickness: 2),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith(
                  (Set<MaterialState> states) => IscteTheme.iscteColor),
            ),
            child: Text(AppLocalizations.of(context)!.timelineSearchButton),
            onPressed: () {
              _submitSelection(context);
            },
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar(BuildContext context, bool isEmptySelectedTopics) {
    return Center(
      child: TextField(
        style: const TextStyle(color: Colors.white),
        controller: searchBarController,
        decoration: InputDecoration(
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              _submitSelection(context);
            },
          ),
          suffixIcon: IconButton(
              icon: const Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: searchBarController.clear),
          hintText: isEmptySelectedTopics
              ? AppLocalizations.of(context)!.timelineSearchHint
              : AppLocalizations.of(context)!.timelineSearchHintInsideTopic,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildTopicsCheckBoxList() {
    return FutureBuilder<List<Topic>>(
      future: availableTopics,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Topic> data = snapshot.data!;
          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 16 / 4),
              semanticChildCount: data.length,
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  activeColor: IscteTheme.iscteColor,
                  value: selectedTopics.contains(data[index]),
                  title: SingleChildScrollView(
                    controller: ScrollController(),
                    scrollDirection: Axis.horizontal,
                    child: Text(data[index].title ?? ""),
                  ),
                  onChanged: (bool? bool) {
                    if (bool != null) {
                      if (bool) {
                        setState(() {
                          selectedTopics.add(data[index]);
                        });
                      } else {
                        setState(() {
                          selectedTopics.remove(data[index]);
                        });
                      }
                      _logger.d(selectedTopics);
                    }
                  },
                );
              });
        } else if (snapshot.hasError) {
          return ErrorWidget(AppLocalizations.of(context)!.generalError);
        } else {
          return const LoadingWidget();
        }
      },
    );
  }

  void _submitSelection(BuildContext context) async {
    Set<Event> setOfEvents = {};
    Iterable<Future<void>> map = selectedTopics.map((e) => e.getEventsList.then(
          (List<Event> value) => setOfEvents.addAll(value),
        ));
    for (Future future in map) {
      await future;
    }
    if (selectedTopics.isEmpty) {
      setOfEvents.addAll(await DatabaseEventTable.getAll());
    }

    _logger.d("events from topics: $setOfEvents");
    String textSearchBar = searchBarController.text.toLowerCase();
    if (textSearchBar.isNotEmpty) {
      setOfEvents = setOfEvents.where((Event element) {
        String eventTitle = (element.title).toLowerCase();
        return eventTitle.contains(textSearchBar) ||
            textSearchBar.contains(eventTitle);
      }).toSet();
      _logger.d("filtered events: $setOfEvents");
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                shape: const ContinuousRectangleBorder(),
              ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.timelineSearchResults),
          ),
          body: TimeLineBody(
            mapdata: setOfEvents.toList(),
          ),
        ),
      ),
    ));
  }
}
