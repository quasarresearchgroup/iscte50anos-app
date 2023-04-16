abstract class QuizException implements Exception {
  abstract final String errorMessage;
}

class TrialQuizNotExistException extends QuizException {
  static int statusCode = 404;
  @override
  final String errorMessage = "Trial or Quiz do not exist";

  TrialQuizNotExistException();
}

class TrialQuestionAlreadyAnsweredException extends QuizException {
  static int statusCode = 400;
  @override
  final String errorMessage = "Question already answered";

  TrialQuestionAlreadyAnsweredException();
}

class TrialQuestionNotAccessedException extends QuizException {
  static int statusCode = 400;
  @override
  final String errorMessage = "Question was not accessed";

  TrialQuestionNotAccessedException();
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
