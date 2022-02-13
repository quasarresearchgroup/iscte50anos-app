import 'package:flutter/material.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';

class Result extends StatelessWidget {
  final int resultScore;
  final Function() resetHandler;

  const Result(this.resultScore, this.resetHandler);

//Remark Logic
  String get resultPhrase {
    String resultText;
    if (resultScore >= 50) {
      resultText = 'Perfeito!';
      print(resultScore);
    }
    if (resultScore >= 41) {
      resultText = 'Muito bom!';
      print(resultScore);
    } else if (resultScore >= 31) {
      resultText = 'Bom desempenho!';
      print(resultScore);
    } else if (resultScore >= 21) {
      resultText = 'Razoável';
    } else if (resultScore >= 10) {
      resultText = 'Fraco';
      print(resultScore);
    } else {
      resultText = 'Zero';
      print(resultScore);
    }
    return resultText;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Quiz 1 concluído",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ), //Text
          /*Text(
            'Pontos: ' '$resultScore',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ), //Text*/
          ElevatedButton(
            child: const Text(
              'Voltar ao menu',
            ), //Te
            onPressed: () {
              Navigator.pushReplacementNamed(context, PageRoutes.home);
            },
          ), //FlatButton
        ], //<Widget>[]
      ), //Column
    ); //Center
  }
}
