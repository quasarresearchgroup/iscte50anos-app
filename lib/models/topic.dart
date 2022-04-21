import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:logger/logger.dart';

class Topic {
  Topic({
    this.id,
    this.description,
    this.qrCodeLink,
  });
  final int? id;
  final String? description;
  final String? qrCodeLink;

  static Logger logger = Logger();

  @override
  String toString() {
    return 'Topic{id: $id, description: $description, qr_code_link: $qrCodeLink}';
  }

  factory Topic.fromMap(Map<String, dynamic> json) => Topic(
        id: json[DatabaseContentTable.columnId],
        description: json[DatabaseContentTable.columnDescription],
        qrCodeLink: json[DatabaseContentTable.columnLink],
      );

  Map<String, dynamic> toMap() {
    return {
      DatabaseContentTable.columnId: id,
      DatabaseContentTable.columnDescription: description,
      DatabaseContentTable.columnLink: qrCodeLink,
    };
  }
}
