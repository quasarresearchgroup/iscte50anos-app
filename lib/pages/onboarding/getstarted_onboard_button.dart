import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

import '../../widgets/nav_drawer/page_routes.dart';

class GetStartedOnboard extends StatelessWidget {
  GetStartedOnboard({
    Key? key,
  }) : super(key: key);

  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _logger.i('Get started');
        Navigator.pushReplacementNamed(context, PageRoutes.home);
      },
      child: SizedBox.expand(
        child: Container(
          color: Theme.of(context).selectedRowColor,
          child: const Center(
            child: Text(
              'Get started',
              style: TextStyle(
                color: Color(0xFF5B16D0),
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
