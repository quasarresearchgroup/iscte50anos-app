import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import './quiz.dart';
import './result.dart';

class QuizPage extends StatefulWidget {
  static const pageRoute = "/quiz";
  Logger logger = Logger();

  QuizPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _QuizPageState();
  }
}

class _QuizPageState extends State<QuizPage> {
  final _questions = const [
    {
      'questionText': 'Em que institutos lecionou Adérito Sedas Nunes?',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/pt/4/40/Ad%C3%A9rito_Sedas_Nunes.jpg',
      'isMultipleChoice': true,
      'answers': [
        {'text': 'Universidade do Porto', 'score': -2},
        {'text': 'Iscte', 'score': -2},
        {'text': 'UNL', 'score': 10},
        {'text': 'Academia Militar', 'score': -2},
      ],
    },
    {
      'questionText': 'Juan Mozzicafreddo foi diretor de que escola do Iscte?',
      'imageUrl': 'https://aps.pt/wp-content/uploads/2019/07/juan-m.jpg',
      'isMultipleChoice': false,
      'answers': [
        {'text': 'ISTA', 'score': -2},
        {'text': 'ESPP', 'score': 10},
        {'text': 'ECSH', 'score': -2},
        {'text': 'IBS', 'score': -2},
        {'text': 'FMH', 'score': -2},
      ],
    },
    {
      'questionText': 'Qual foi a área de estudo de Mário Murteira',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/pt/thumb/7/76/M%C3%A1rio_Murteira.jpg/200px-M%C3%A1rio_Murteira.jpg',
      'isMultipleChoice': false,
      'answers': [
        {'text': 'Arquitetura', 'score': -2},
        {'text': 'Tecnologias de Informação', 'score': -2},
        {'text': 'Economia', 'score': 10},
        {'text': 'Ciência Política', 'score': -2},
      ],
    },
    {
      'questionText': 'Em qual destes países estudou Raúl Hestnes Ferreira?',
      'imageUrl':
          'https://cdn-images.rtp.pt/arquivo/2016/12/raul-hestnes-ferreira_1481296052.png?ixlib=php-1.1.0',
      'isMultipleChoice': false,
      'answers': [
        {'text': 'Alemanha', 'score': -2},
        {'text': 'Suécia', 'score': -2},
        {'text': 'Japão', 'score': -2},
        {'text': 'Estados Unidos da América', 'score': 10},
      ],
    },
    {
      'questionText':
          'José Paquete de Oliveira exerceu funções na estação televisiva da SIC?',
      'imageUrl':
          'https://static.globalnoticias.pt/storage/DN/2016/original/ng7013294.jpg',
      'isMultipleChoice': false,
      'answers': [
        {
          'text': 'Sim',
          'score': -2,
        },
        {'text': 'Não', 'score': 10},
      ],
    },
  ];

  var _questionIndex = 0;
  var _totalScore = 0;

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalScore = 0;
    });
  }

  void _answerQuestion(int score) {
    _totalScore += score;

    setState(() {
      _questionIndex = _questionIndex + 1;
    });

    widget.logger.i(_questionIndex);
    if (_questionIndex < _questions.length) {
      widget.logger.i('We have more questions!');
    } else {
      widget.logger.i('No more questions!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.quizPageTitle),
          //backgroundColor: const Color.fromRGBO(200, 200, 200, 0),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _questionIndex < _questions.length
              ? Quiz(
                  questions: _questions,
                  answerQuestion: _answerQuestion,
                  questionIndex: _questionIndex)
              : Result(_totalScore, _resetQuiz),
        ), //Padding
      ), //Scaffold
      debugShowCheckedModeBanner: false,
    ); //MaterialApp
  }
}
