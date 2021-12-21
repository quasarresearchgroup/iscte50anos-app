class TimeLineData {
  TimeLineData(this.data, String date) {
    List<String> dateSplit = date.split("-");
    year = int.parse(dateSplit[2]);
    month = int.parse(dateSplit[1]);
    day = int.parse(dateSplit[0]);
  }

  late final int year;
  late final int month;
  late final int day;
  String? location;
  late final String data;

  String getDateString() {
    return year.toString() + "-" + month.toString() + "-" + day.toString();
  }
}
