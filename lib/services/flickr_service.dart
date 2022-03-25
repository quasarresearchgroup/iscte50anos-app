import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

abstract class FlickrService<T> {
  @protected
  final Logger logger = Logger();
  bool fetching = false;
  String? key;
  static const String userID = "45216724@N07";
  static int NODATAERROR = 1;
  Stream<T> get stream;

  FlickrService() {
    key = dotenv.env["FLICKR_KEY"];
    if (key == null) {
      throw Exception("No API key");
    }
  }

  void startFetch() {
    fetching = true;
  }

  void stopFetch() {
    fetching = false;
  }
}
