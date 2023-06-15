import 'package:flutter/material.dart';

class FlickrServiceNoDataException implements Exception {
  @override
  String toString() => "FlickrServiceNoDataException";
}

class FlickrServiceNoMoreDataException implements Exception {
  @override
  String toString() => "FlickrServiceNoMoreDataException";
}

abstract class FlickrService<T> {
  @protected
  bool fetching = false;
  static String key = "c16f27dcc1c8674dd6daa3a26bd24520";
  static const String userID = "45216724@N07";

  Stream<T> get stream;

  void startFetch() {
    fetching = true;
  }

  void stopFetch() {
    fetching = false;
  }
}
