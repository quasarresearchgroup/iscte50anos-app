class SpotInfoRequest {
  SpotInfoRequest({
    required this.title,
    required this.visited,
    required this.id,
  });
  final String title;
  final int id;
  final bool visited;

  @override
  String toString() {
    return 'SpotRequest{title: $title, id: $id, visited: $visited}';
  }

  factory SpotInfoRequest.fromMap(Map<String, dynamic> json) => SpotInfoRequest(
        id: json["id"],
        title: json["title"],
        visited: json["visited"],
      );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "visited": visited,
    };
  }
}
