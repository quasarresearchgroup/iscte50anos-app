class SpotInfoRequest {
  SpotInfoRequest({
    required this.title,
    this.id,
  });
  final String? title;
  final int? id;

  @override
  String toString() {
    return 'SpotRequest{title: $title, id: $id}';
  }

  factory SpotInfoRequest.fromMap(Map<String, dynamic> json) =>
      SpotInfoRequest(id: json["id"], title: json["title"]);

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
    };
  }
}
