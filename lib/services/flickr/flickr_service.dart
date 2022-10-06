import 'package:flutter/material.dart';


abstract class FlickrService<T> {
  @protected
  bool fetching = false;
  static String key = "c16f27dcc1c8674dd6daa3a26bd24520";
  static const String userID = "45216724@N07";
  static const int noDataError = 1;
  Stream<T> get stream;

  void startFetch() {
    fetching = true;
  }

  void stopFetch() {
    fetching = false;
  }
}
