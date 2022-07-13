import 'package:flutter/material.dart';

class NetworkError extends StatelessWidget {

  final Function() onRefresh;

  const NetworkError({Key? key, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRefresh,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Ocorreu um erro a descarregar os dados'),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'Tocar aqui para recarregar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
