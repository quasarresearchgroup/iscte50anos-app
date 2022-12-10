import 'package:logger/logger.dart';

class Topic {
  Topic({
    required this.id,
    this.title,
  });

  final int id;
  final String? title;

  static Logger logger = Logger();

  @override
  String toString() {
    return 'Topic{id: $id, title: $title}';
  }

  String get asString {
    return "topic=$id";
  }

  factory Topic.fromString(String string) {
    //final List<String> split = string.split(":");
    //final int? id = int.tryParse(split[0]);
    final int? id = int.tryParse(string.replaceFirst("topic=", ""));
    if (id == null) {
      throw const FormatException();
    }
    return Topic(
      id: id,
      //title: split[1],
    );
  }
  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Topic &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

/*
  Future<List<Event>> get getEventsList async {
    return TimelineTopicService.fetchEvents(topicIds: [id]);
    assert(id != null);
    List<int> allIdsWithEventId =
        await DatabaseEventTopicTable.getEventIdsFromTopicId(id!);
    List<Event> topicsList =
        await DatabaseEventTable.getAllWithIds(allIdsWithEventId);
    return topicsList;
  }
  */
}
