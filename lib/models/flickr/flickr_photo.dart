class FlickrPhoto {
  FlickrPhoto({
    required this.title,
    required this.id,
    required this.server,
    required this.secret,
    required this.farm,
    this.isPrimary,
  });

  //<photo id="2484" secret="123456" server="1" title="my photo" isprimary="0" />
  String id;
  String secret;
  String server;
  String title;
  int farm;
  bool? isPrimary;

  String get url =>
      "https://farm$farm.staticflickr.com/$server/$id\_$secret\_z.jpg";

  @override
  String toString() {
    return 'FlickrPhoto{id: $id, secret: $secret, server: $server, title: $title, isPrimary: $isPrimary}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlickrPhoto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          secret == other.secret &&
          server == other.server &&
          title == other.title &&
          farm == other.farm &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode =>
      id.hashCode ^
      secret.hashCode ^
      server.hashCode ^
      title.hashCode ^
      farm.hashCode ^
      isPrimary.hashCode;

  factory FlickrPhoto.fromMap(Map<String, dynamic> json) => FlickrPhoto(
        id: json["id"],
        server: json["server"],
        secret: json["secret"],
        isPrimary: json["isPrimary"],
        title: json["title"],
        farm: json["farm"],
      );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "secret": secret,
      "server": server,
      "title": title,
      "isPrimary": isPrimary,
      "farm": farm,
    };
  }
}
