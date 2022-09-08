



import 'package:logger/logger.dart';
import 'dart:developer' as dartdev;

class LoggerService{


  LoggerService._privateConstructor();

  static final LoggerService _instance =
  LoggerService._privateConstructor();

  static LoggerService get instance => _instance;

  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 5,errorMethodCount: 10));

  void verbose(dynamic arg){
    _logger.v(arg);
    dartdev.log(arg);
  }
  void debug(dynamic arg){
   _logger.d(arg);
   dartdev.log(arg);
  }
  void info(dynamic arg){
    _logger.i(arg);
    dartdev.log(arg);
  }
  void warning(dynamic arg){
    _logger.w(arg);
    dartdev.log(arg);
  }
  void error(dynamic arg){
    _logger.e(arg);
    dartdev.log(arg);
  }
  void wtf(dynamic arg){
    _logger.wtf(arg);
    dartdev.log(arg);
  }

  void log(Level level, dynamic arg){
    _logger.log(level, arg);
    dartdev.log(arg);
  }




}
