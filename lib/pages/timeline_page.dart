import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_reader/widgets/timeline/events_timeline.dart';
import 'package:qr_code_reader/widgets/timeline/year_timeline.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({Key? key}) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  int chosenYear = 1972;

  final Map<String, String> timeLineMap = {
    "31-10-1972": "296 estudantes",
    "15-12-1972": "Criação do ISCTE",
    "21-12-1972": "	Estudante nº 1 Abel dos Santos Alves, licenciatura OGE",
    "01-01-1973": "	CEE: adesão da Dinamarca, Irlanda, Reino Unido",
    "11-08-1973":
        "	Integração do ISCTE na Universidade Nova de Lisboa recém-criada",
    "11-09-1973": "	Chile: Derrube do governo de Salvador Allende",
    "24-09-1973": "	Guiné-Bissau: declaração unilateral de independência",
    "25-04-1974": "	Portugal: Revolução dos Cravos",
    "24-07-1974": "	Grécia: Queda da ditadura dos Coronéis",
    "26-08-1974": "	Independência de Cabo Verde",
    "01-01-1975":
        "	Constituição do Centro de Estudos de História Contemporânea Portuguesa (CEHCP)",
    "30-04-1975": "	Rendição de Saigão. Fim da Guerra do Vietname",
  };
  final List<int> yearsList = <int>[
    1972,
    1973,
    1974,
    1975,
    1976,
    1977,
    1978,
    1979,
    1980
  ];
  final lineStyle = const LineStyle(color: Colors.black, thickness: 6);

  void changeChosenYear(int year) {
    setState(() {
      chosenYear = year;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            flex: 2,
            child: YearTimeline(
              lineStyle: lineStyle,
              changeYearFunction: changeChosenYear,
              yearsList: yearsList,
            ),
          ),
          Expanded(
            flex: 8,
            child: EventsTimeline(
              lineStyle: lineStyle,
              timelineYear: chosenYear,
              timeLineMap: timeLineMap,
            ),
          ),
        ]),
      ),
    );
  }
}
