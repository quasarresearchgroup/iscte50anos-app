import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import './quiz.dart';
import './result.dart';

//Main for isolated testing
void main(){
  runApp(MaterialApp(home:QuizPage()));
}

class QuizPage extends StatefulWidget {
  static const pageRoute = "/quiz";
  final Logger logger = Logger();

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
        {'text': 'Universidade do Porto', 'score': -2,'id':1},
        {'text': 'Iscte', 'score': -2,'id':2},
        {'text': 'UNL', 'score': 10,'id':3},
        {'text': 'Academia Militar', 'score': -2,'id':4},
      ],
    },
    {
      'questionText': 'Juan Mozzicafreddo foi diretor de que escola do Iscte?',
      'imageUrl': 'https://aps.pt/wp-content/uploads/2019/07/juan-m.jpg',
      'isMultipleChoice': true,
      'answers': [
        {'text': 'ISTA', 'score': -2,'id':5},
        {'text': 'ESPP', 'score': 10,'id':6},
        {'text': 'ECSH', 'score': -2,'id':7},
        {'text': 'IBS', 'score': -2,'id':8},
      ],
    },
    {
      'questionText': 'Qual foi a área de estudo de Mário Murteira',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/pt/thumb/7/76/M%C3%A1rio_Murteira.jpg/200px-M%C3%A1rio_Murteira.jpg',
      'isMultipleChoice': true,
      'answers': [
        {'text': 'Arquitetura', 'score': -2,'id':9},
        {'text': 'Tecnologias de Informação', 'score': -2,'id':10},
        {'text': 'Economia', 'score': 10,'id':11},
        {'text': 'Ciência Política', 'score': -2,'id':12},
      ],
    },
    {
      'questionText': 'Em qual destes países estudou Raúl Hestnes Ferreira?',
      'imageUrl':
          'https://cdn-images.rtp.pt/arquivo/2016/12/raul-hestnes-ferreira_1481296052.png?ixlib=php-1.1.0',
      'isMultipleChoice': false,
      'answers': [
        {'text': 'Alemanha', 'score': -2,'id':13},
        {'text': 'Suécia', 'score': -2,'id':14},
        {'text': 'Japão', 'score': -2,'id':15},
        {'text': 'Estados Unidos da América', 'score': 10,'id':16},
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
          'id':17
        },
        {'text': 'Não', 'score': 10,'id':18},
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
    // TODO send answers to server
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
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.quizPageTitle ?? "Quiz"),
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
      );
  }
}
