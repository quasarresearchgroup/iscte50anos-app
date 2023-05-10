import 'package:iscte_spots/services/logging/LoggerService.dart';

class Quiz {
  int number;
  int max_num_trials;
  int num_trials;
  int score;
  List<String> topic_names;
  List<TrialInfo> trials;

  Quiz({
    required this.number,
    required this.max_num_trials,
    required this.num_trials,
    required this.score,
    required this.topic_names,
    required this.trials,
  });

  @override
  String toString() {
    return 'Quiz{number: $number, max_num_trials: $max_num_trials, num_trials: $num_trials, score: $score, topic_names: $topic_names, trials: $trials}';
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    LoggerService.instance.debug(json);
    return Quiz(
      number: json["number"],
      max_num_trials: json["max_num_trials"],
      num_trials: json["num_trials"],
      score: json["score"],
      topic_names: (json["topic_names"] as String).split(";"),
      trials: (json["trials"] as List<dynamic>)
          .map((e) => TrialInfo.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "number": number,
      "max_num_trials": max_num_trials,
      "num_trials": num_trials,
      "score": score,
      "topic_names": topic_names.join("; "),
      "trials": trials.map((e) => e.toJson()).toList(),
    };
  }
}

class TrialInfo {
  int number;
  int progress;
  bool is_completed;
  int score;
  int quiz_size;

  TrialInfo({
    required this.number,
    required this.progress,
    required this.is_completed,
    required this.score,
    required this.quiz_size,
  });

  @override
  String toString() {
    return 'TrialInfo{number: $number, progress: $progress, is_completed: $is_completed, score: $score, quiz_size: $quiz_size}';
  }

  factory TrialInfo.fromJson(Map<String, dynamic> json) => TrialInfo(
        number: json["number"],
        progress: json["progress"],
        is_completed: json["is_completed"],
        score: json["score"],
        quiz_size: json["quiz_size"],
      );

  Map<String, dynamic> toJson() {
    return {
      "number": number,
      "progress": progress,
      "is_completed": is_completed,
      "score": score,
      "quiz_size": quiz_size,
    };
  }
}
