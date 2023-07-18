import 'dart:convert';

import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class TimelineFilterParams {
  TimelineFilterParams({
    Set<Topic>? topics,
    Set<EventScope>? scopes,
    String searchText = "",
  })  : _topics = topics ?? {},
        _scopes = scopes ?? {},
        _searchText = searchText;

  final Set<Topic> _topics;
  final Set<EventScope> _scopes;
  final String _searchText;
  Set<Topic> get topics => _topics;
  Set<EventScope> get scopes => _scopes;
  String get searchText => _searchText;

  TimelineFilterParams set({
    Set<Topic>? newTopics,
    Set<EventScope>? scopes,
    String? searchText,
  }) {
    return TimelineFilterParams(
        topics: newTopics ?? _topics,
        scopes: scopes ?? _scopes,
        searchText: searchText ?? this.searchText);
  }

  TimelineFilterParams setsearchText(Set<Topic> value) {
    return TimelineFilterParams(
        topics: value, searchText: searchText, scopes: _scopes);
  }

  bool isTopicsEmpty() => _topics.isEmpty;

  TimelineFilterParams addTopic(Topic topic) {
    return set(newTopics: topics..add(topic));
  }

  TimelineFilterParams removeTopic(Topic topic) {
    return set(newTopics: topics..remove(topic));
  }

  TimelineFilterParams clearTopics() {
    return set(newTopics: topics..clear());
  }

  bool containsTopic(Topic topic) => _topics.contains(topic);

  TimelineFilterParams addAllTopic(Iterable<Topic> iterableTopics) {
    return set(newTopics: topics..addAll(iterableTopics));
  }
  //endregion

  //region Scopes

  bool isScopesEmpty() => _scopes.isEmpty;

  TimelineFilterParams addScope(EventScope scope) {
    return set(scopes: scopes..add(scope));
  }

  TimelineFilterParams removeScope(EventScope scope) {
    return set(scopes: scopes..remove(scope));
  }

  TimelineFilterParams clearScopes() {
    return set(scopes: scopes..clear());
  }

  bool containsScope(EventScope scope) => _scopes.contains(scope);

  TimelineFilterParams addAllScope(Iterable<EventScope> iterableScopes) {
    return set(scopes: scopes..addAll(iterableScopes));
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
    LoggerService.instance.debug("map\n$map");
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
