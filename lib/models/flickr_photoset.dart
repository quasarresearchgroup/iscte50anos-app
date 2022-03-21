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
