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
}
