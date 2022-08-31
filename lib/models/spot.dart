import 'database/tables/database_spot_table.dart';

class Spot {
  Spot({
    required this.id,
    required this.photoLink,
    this.visited = false,
  });
  final int id;
  final String photoLink;
  bool visited;

  @override
  String toString() {
    return 'Spot{id: $id, photoLink: $photoLink, visited: $visited}';
  }

  factory Spot.fromMap(Map<String, dynamic> json) => Spot(
        id: json[DatabaseSpotTable.columnId],
        photoLink: json[DatabaseSpotTable.columnPhotoLink],
        visited: json[DatabaseSpotTable.columnVisited] == 1 ? true : false,
      );

  Map<String, dynamic> toMap() {
    return {
      DatabaseSpotTable.columnId: id,
      DatabaseSpotTable.columnPhotoLink: photoLink,
      DatabaseSpotTable.columnVisited: visited ? 1 : 0,
    };
  }
}
