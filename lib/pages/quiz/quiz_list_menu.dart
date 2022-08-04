import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/pages/quiz/quiz_page.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:logger/logger.dart';

import '../../services/quiz/quiz_service.dart';
import '../../widgets/network/error.dart';

//const API_ADDRESS = "http://192.168.1.124";

//const API_ADDRESS_PROD = "https://194.210.120.48";
//const API_ADDRESS_TEST = "http://192.168.1.124";
const MAX_TRIALS = 3;

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

// FOR ISOLATED TESTING
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: QuizMenu()));
}

class QuizMenu extends StatefulWidget {
  static const pageRoute = "/quiz_menu";

  const QuizMenu({Key? key}) : super(key: key);

  @override
  State<QuizMenu> createState() => _QuizMenuState();
}

class _QuizMenuState extends State<QuizMenu>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final Logger logger = Logger();
  late TabController _tabController;
  int _selectedIndex = 0;

  //Page Selection Mechanics
  void _onItemTapped(int index) {
    setState(() {
      _tabController.animateTo(index);
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: MyAppBar(
        title: "Quiz",
        leading:
            DynamicBackIconButton(), //AppLocalizations.of(context)!.quizPageTitle)
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child:
            const QuizListPage(), /*TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: _pages,
        ),*/ // _pages[_selectedIndex],
      ),
      /*bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: IscteTheme.appbarRadius,
          topRight: IscteTheme.appbarRadius,
        ),
        child: BottomNavigationBar(
          //type: BottomNavigationBarType.shifting,
          type: BottomNavigationBarType.shifting,
          backgroundColor: Theme.of(context).primaryColor,
          selectedItemColor: Theme.of(context).selectedRowColor,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
          elevation: 8,
          enableFeedback: true,
          iconSize: 30,
          selectedFontSize: 13,
          unselectedFontSize: 10,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          //selectedItemColor: Colors.amber[800],
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.globe),
              backgroundColor: Theme.of(context).primaryColor,
              label: 'Global',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.group),
              backgroundColor: Theme.of(context).primaryColor,
              label: 'Afiliação',
            ),
          ],
        ),
      ),*/
    );
  }
}

class QuizListPage extends StatelessWidget {
  const QuizListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(
          // Container to hold the description
          height: 50,
          child: Center(
            child: Text("Quizzes disponíveis",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        Expanded(child: QuizList()),
      ],
    );
  }
}

class QuizList extends StatefulWidget {
  const QuizList({Key? key}) : super(key: key);

  @override
  _QuizListState createState() => _QuizListState();
}

class _QuizListState extends State<QuizList> {
  final fetchFunction = QuizService.getQuizList;
  late Future<List<dynamic>> futureQuizList;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureQuizList = fetchFunction();
  }

  startTrial(int quizNumber) async {
    Map newTrialInfo = await QuizService.startTrial(quizNumber);
    int newTrialNumber = newTrialInfo["trial_number"];

    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => QuizPage(
                  quizNumber: quizNumber,
                  trialNumber: newTrialNumber,
                )))
        .then((value) {
      setState(() {
        futureQuizList = fetchFunction();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureQuizList,
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          var items = snapshot.data as List<dynamic>;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                if (!isLoading) {
                  futureQuizList = fetchFunction();
                }
              });
            },
            child: items.isEmpty
                ? const Center(
                    child: Text("Não existem Quizzes disponíveis de momento"))
                : ListView.builder(
                    //shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      int quizNumber = items[index]["number"];
                      int trials = items[index]["num_trials"];
                      return Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Card(
                          child: ExpansionTile(
                            title: Text(
                                "Quiz ${items[index]["number"].toString()}", //items[index]["username"].toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text(
                                "Pontos: ${items[index]["score"]} \nTentativas: ${items[index]["num_trials"]}"
                                "\nTopicos: ${items[index]["topic_names"]}"),
                            children: [
                              trials >= MAX_TRIALS
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const <Widget>[
                                        Text("Completo"),
                                      ],
                                    )
                                  : (PlatformService.instance.isIos)
                                      ? CupertinoButton(
                                          child: const Text("Iniciar"),
                                          onPressed: () {
                                            showStartQuizDialog(
                                                context, quizNumber);
                                          })
                                      : ElevatedButton(
                                          child: const Text("Iniciar"),
                                          onPressed: () {
                                            showStartQuizDialog(
                                                context, quizNumber);
                                          }),
                            ],
                            //minVerticalPadding: 10.0,
                          ),
                        ),
                      );
                    },
                  ),
          );
        } else if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: SizedBox(
              child: CircularProgressIndicator.adaptive(),
              width: 60,
              height: 60,
            ),
          );
        } else if (snapshot.hasError) {
          return NetworkError(onRefresh: () {
            setState(() {
              futureQuizList = fetchFunction();
            });
          });
        } else {
          return const Center(
            child: SizedBox(
              child: CircularProgressIndicator.adaptive(),
              width: 60,
              height: 60,
            ),
          );
        }
      },
    );
  }

  void showStartQuizDialog(BuildContext context, int quizNumber) {
    DynamicAlertDialog.showDynamicDialog(
      useRootNavigator: false,
      context: context,
      title: const Center(child: Text("Aviso")),
      content: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 14.0,
          ),
          children: <TextSpan>[
            TextSpan(text: 'Deseja iniciar uma tentativa de Quiz?\n'),
            TextSpan(
                text: '(Certifique-se que tem uma conexão estável)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      actions: (PlatformService.instance.isIos)
          ? [
              CupertinoButton(
                child: const Text('Não'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoButton(
                child: const Text('Sim'),
                onPressed: () {
                  Navigator.of(context).pop();
                  startTrial(quizNumber);
                },
              ),
            ]
          : [
              TextButton(
                child: const Text('Não'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Sim'),
                onPressed: () {
                  Navigator.of(context).pop();
                  startTrial(quizNumber);
                },
              ),
            ],
    );
  }
}
