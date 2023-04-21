abstract class QuizException implements Exception {
  abstract final String errorMessage;
}

class TrialQuizNotExistException extends QuizException {
  static int statusCode = 404;
  @override
  final String errorMessage = "Trial or Quiz do not exist";

  TrialQuizNotExistException();
}

class TrialAlreadyAnsweredException extends QuizException {
  static int statusCode = 400;
  @override
  final String errorMessage = "Trial already answered";

  TrialAlreadyAnsweredException();
}

class TrialInvalidAnswerException extends QuizException {
  static int statusCode = 400;
  @override
  final String errorMessage = "Invalid answer";

  TrialInvalidAnswerException();
}

class TrialInvalidBodyException extends QuizException {
  static int statusCode = 400;
  @override
  final String errorMessage = "Invalid body";

  TrialInvalidBodyException();
}

class TrialFailedContinue extends QuizException {
  @override
  final String errorMessage = "Failed to continue trial";
}

class TrialFailedStart extends QuizException {
  @override
  final String errorMessage = "Failed to start trial";
}

class TrialFailedSubmitAnswer extends QuizException {
  @override
  final String errorMessage = "Failed to submit answer";
}

class TriaAnswerTimeExpired extends QuizException {
  @override
  final String errorMessage = "Answer time has expired";
}
