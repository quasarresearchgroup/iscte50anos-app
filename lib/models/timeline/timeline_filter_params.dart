import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:logger/logger.dart';

class TimelineFilterParams with ChangeNotifier {
  TimelineFilterParams({
    Set<Topic>? topics,
    Set<EventScope>? scopes,
    String searchText = "",
  })  : _topics = topics ?? {},
        _scopes = scopes ?? {},
        _searchText = searchText;

  final Logger _logger = Logger();

  Set<Topic> _topics;
  Set<EventScope> _scopes;

  String _searchText;
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
    _logger.i(this);
  }

  //region Topics
  Set<Topic> get getTopics => _topics;
  set topics(Set<Topic> value) {
    _topics = value;
    notifyListeners();
    _logger.i(this);
  }

  bool isTopicsEmpty() => _topics.isEmpty;

  void addTopic(Topic topic) {
    _topics.add(topic);
    notifyListeners();
    _logger.i(this);
  }

  void removeTopic(Topic topic) {
    _topics.remove(topic);
    notifyListeners();
    _logger.i(this);
  }

  void clearTopics() {
    _topics.clear();
    notifyListeners();
    _logger.i(this);
  }

  bool containsTopic(Topic topic) => _topics.contains(topic);

  void addAllTopic(Iterable<Topic> iterableTopics) {
    _topics.addAll(iterableTopics);
    _logger.i(this);
    notifyListeners();
  }
  //endregion

  //region Scopes

  Set<EventScope> get getScopes => _scopes;

  set scopes(Set<EventScope> value) {
    _scopes = value;
    _logger.i(this);
    notifyListeners();
  }

  bool isScopesEmpty() => _scopes.isEmpty;

  void addScope(EventScope scope) {
    _scopes.add(scope);
    _logger.i(this);
    notifyListeners();
  }

  void removeScope(EventScope scope) {
    _scopes.remove(scope);
    _logger.i(this);
    notifyListeners();
  }

  void clearScopes() {
    _scopes.clear();
    _logger.i(this);
    notifyListeners();
  }

  bool containsScope(EventScope scope) => _scopes.contains(scope);

  void addAllScope(Iterable<EventScope> iterableScopes) {
    _scopes.addAll(iterableScopes);
    _logger.i(this);
    notifyListeners();
  }

  //endregion

  factory TimelineFilterParams.fromMap(Map<String, dynamic> json) {
    return TimelineFilterParams(
      topics: jsonDecode(json["topics"]),
      scopes: json["scopes"],
      searchText: json["searchText"],
    );
  }

  Map<String, dynamic> toMap() {
    var map = {
      "topics": json.encode(_topics.toList()),
      "scopes": json.encode(_scopes.map((e) => e.name).toList()),
      "searchText": json.encode(_searchText),
    };
    _logger.d("map\n$map");
    return map;
  }

  String encode() {
    //return base64Url.encode(utf8.encode(outputString));
    return "${_topics.map((e) => e.asString).join("&")}_${_scopes.map((e) => e.asString).join("&")}_search=$_searchText";
  }

  factory TimelineFilterParams.decode(String hash) {
    //String base64decode = utf8.decode(base64Url.decode(hash));
    //Logger().d(base64decode);
    List<String> split = hash.split("_");
    Set<EventScope> scopes = {};
    Set<Topic> topics = {};
    String searchText = "";
    try {
      List<String> topicsString = split[0].split("&");
      topics = topicsString.map((e) => Topic.fromString(e)).toSet();
    } catch (_) {
      rethrow;
    }
    try {
      List<String> scopesString = split[1].split("&");
      for (String entry in scopesString) {
        EventScope? eventScope = decodeEventScopefromString(entry);
        if (eventScope != null) {
          scopes.add(eventScope);
        }
      }
    } catch (_) {
      rethrow;
    }
    try {
      searchText = split[2].replaceFirst("search=", "");
    } catch (_) {
      rethrow;
    }

    return TimelineFilterParams(
        scopes: scopes, searchText: searchText, topics: topics);
  }

  @override
  String toString() {
    return 'TimelineFilterParams{_topics: $_topics, _scopes: $_scopes, _searchText: $_searchText}';
  }
}
