import 'package:logger/logger.dart';

class LoggerService {
  LoggerService._privateConstructor();

  static final LoggerService _instance = LoggerService._privateConstructor();

  static LoggerService get instance => _instance;

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      printTime: true,
      noBoxingByDefault: false,
      methodCount: 5,
      errorMethodCount: 10,
    ),
  );

  void verbose(dynamic arg) {
    _logger.v(arg);
  }

  void debug(dynamic arg) {
    _logger.d(arg);
  }

  void info(dynamic arg) {
    _logger.i(arg);
  }

  void warning(dynamic arg) {
    _logger.w(arg);
  }

  void error(dynamic arg) {
    _logger.e(arg);
  }

  void wtf(dynamic arg) {
    _logger.wtf(arg);
  }

  void log(Level level, dynamic arg) {
    _logger.log(level, arg);
  }
}
