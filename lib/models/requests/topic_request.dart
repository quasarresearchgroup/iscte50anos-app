import 'package:iscte_spots/models/timeline/content.dart';

class TopicRequest {
  TopicRequest({
    required this.title,
    required this.contentList,
  });

  final String? title;
  final List<Content>? contentList;

  @override
  String toString() {
    return 'TopicRequest{title: $title, contentList: $contentList}';
  }

  factory TopicRequest.fromMap(Map<String, dynamic> json) => TopicRequest(
        title: json["locationPhotoLink"],
        contentList: json["contentList"],
      );

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "contentList": contentList,
    };
  }
}
