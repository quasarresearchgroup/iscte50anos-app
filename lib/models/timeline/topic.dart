import 'package:iscte_spots/models/database/tables/database_event_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_topic_table.dart';
import 'package:iscte_spots/models/database/tables/database_topic_table.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:logger/logger.dart';

class Topic {
  Topic({
    this.id,
    this.title,
  });
  final int? id;
  final String? title;

  static Logger logger = Logger();

  @override
  String toString() {
    return 'Topic{id: $id, title: $title}';
  }

  factory Topic.fromMap(Map<String, dynamic> json) => Topic(
        id: json[DatabaseTopicTable.columnId],
        title: json[DatabaseTopicTable.columnTitle],
      );

  Map<String, dynamic> toMap() {
    return {
      DatabaseTopicTable.columnId: id,
      DatabaseTopicTable.columnTitle: title,
    };
  }

  Future<List<Event>> get getEventsList async {
    assert(id != null);
    List<int> allIdsWithEventId =
        await DatabaseEventTopicTable.getEventIdsFromTopicId(id!);
    List<Event> topicsList =
        await DatabaseEventTable.getAllWithIds(allIdsWithEventId);
    return topicsList;
  }
}
