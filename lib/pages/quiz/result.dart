import 'package:flutter/material.dart';

class Result extends StatelessWidget {
  final int resultScore;
  final Function() resetHandler;

  Result(this.resultScore, this.resetHandler);

//Remark Logic
  String get resultPhrase {
    String resultText;
    if(resultScore >= 50){
      resultText = 'Perfeito!';
      print(resultScore);
    }if (resultScore >= 41) {
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
    }else{
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
          Text(
            resultPhrase,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ), //Text
          Text(
            'Pontos: ' '$resultScore',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ), //Text
          ElevatedButton(
            child: Text(
              'Reiniciar Quiz',
            ), //Te
            onPressed: resetHandler,
          ), //FlatButton
        ], //<Widget>[]
      ), //Column
    ); //Center
  }
}
