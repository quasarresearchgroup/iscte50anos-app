class SpotRequest {
  SpotRequest({
    required this.locationPhotoLink,
    required this.statusCode,
    this.spotNumber,
  });
  final String? locationPhotoLink;
  final int? spotNumber;
  final int statusCode;

  @override
  String toString() {
    return 'SpotRequest{locationPhotoLink: $locationPhotoLink, spotNumber: $spotNumber, statusCode: $statusCode}';
  }

  factory SpotRequest.fromMap(Map<String, dynamic> json) => SpotRequest(
        locationPhotoLink: json["locationPhotoLink"],
        statusCode: json["statusCode"],
        spotNumber: json["spotNumber"],
      );

  Map<String, dynamic> toMap() {
    return {
      "locationPhotoLink": locationPhotoLink,
      "statusCode": statusCode,
      "spotNumber": spotNumber,
    };
  }
}
