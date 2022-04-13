class FlickrPhotoset {
  FlickrPhotoset({
    required this.title,
    required this.description,
    required this.id,
    required this.farm,
    required this.server,
    required this.photoN,
    this.primaryphotoID,
    this.primaryphotoURL,
  });

  String title;
  String description;
  String id;
  int farm;
  String server;
  int photoN;
  String? primaryphotoID;
  String? primaryphotoURL;

  @override
  String toString() {
    return 'FlickrPhotoset{title: $title, description: $description, id: $id, farm: $farm, server: $server, photoN: $photoN, primaryphotoID: $primaryphotoID, primaryphotoURL: $primaryphotoURL}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlickrPhotoset &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          description == other.description &&
          id == other.id &&
          farm == other.farm &&
          server == other.server &&
          photoN == other.photoN &&
          primaryphotoID == other.primaryphotoID &&
          primaryphotoURL == other.primaryphotoURL;

  @override
  int get hashCode =>
      title.hashCode ^
      description.hashCode ^
      id.hashCode ^
      farm.hashCode ^
      server.hashCode ^
      photoN.hashCode ^
      primaryphotoID.hashCode ^
      primaryphotoURL.hashCode;

  factory FlickrPhotoset.fromMap(Map<String, dynamic> json) => FlickrPhotoset(
        title: json["title"],
        description: json["description"],
        id: json["id"],
        farm: json["farm"],
        server: json["server"],
        photoN: json["photoN"],
        primaryphotoID: json["primaryphotoID"],
        primaryphotoURL: json["primaryphotoURL"],
      );

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "id": id,
      "farm": farm,
      "server": server,
      "photoN": photoN,
      "primaryphotoID": primaryphotoID,
      "primaryphotoURL": primaryphotoURL,
    };
  }
}
