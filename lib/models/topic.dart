import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:logger/logger.dart';

class Topic {
  Topic({
    this.id,
    this.description,
    this.qr_code_link,
  });
  final int? id;
  final String? description;
  final String? qr_code_link;

  static Logger logger = Logger();

  @override
  String toString() {
    return 'Topic{id: $id, description: $description, qr_code_link: $qr_code_link}';
  }

  factory Topic.fromMap(Map<String, dynamic> json) => Topic(
        id: json[DatabaseContentTable.columnId],
        description: json[DatabaseContentTable.columnDescription],
        qr_code_link: json[DatabaseContentTable.columnLink],
      );

  Map<String, dynamic> toMap() {
    return {
      DatabaseContentTable.columnId: id,
      DatabaseContentTable.columnDescription: description,
      DatabaseContentTable.columnLink: qr_code_link,
    };
  }
}
