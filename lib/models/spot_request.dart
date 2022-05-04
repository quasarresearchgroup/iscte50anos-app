class SpotRequest {
  SpotRequest({
    required this.location_photo_link,
    this.spot_number,
  });
  final String? location_photo_link;
  final int? spot_number;

  @override
  String toString() {
    return 'SpotRequest{location_photo_link: $location_photo_link, spot_number: $spot_number}';
  }
}
