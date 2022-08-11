import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/models/database/tables/database_topic_table.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
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

  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    availableTopics = DatabaseTopicTable.getAll();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchBarController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: TextField(
            controller: searchBarController,
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: searchBarController.clear,
              ),
              suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: searchBarController.clear),
              hintText: 'Search...',
              border: InputBorder.none,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<Topic>>(
          future: availableTopics,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Topic>? data = snapshot.data;
              return ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      value: selectedTopics.contains(data[index]),
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
                      title: Text(data[index].title ?? ""),
                    );
                  });
/*
              return DropdownButton<Topic>(
                isExpanded: true,
                value: selectedTopic,
                style: const TextStyle(color: Colors.white),
                items: snapshot.data
                    ?.map(
                      (topic) => DropdownMenuItem(
                        value: topic,
                        child: Text(topic.title ?? ""),
                      ),
                    )
                    .toList(),
                selectedItemBuilder: (context) => snapshot.data!
                    .map(
                      (e) => Center(
                        child: Text(
                          e.title ?? "",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (Topic? newValue) {
                  _logger.d("Choosen new Topic $newValue");
                  setState(() {
                    selectedTopic = newValue;
                  });
                },
              );
*/
            } else if (snapshot.hasError) {
              return ErrorWidget("Error on Topic load");
            } else {
              return const LoadingWidget();
            }
          },
        ),
      ),
    );
  }
}
