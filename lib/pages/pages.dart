import 'package:ISCTE_50_Anos/models/page.dart';
import 'package:flutter/material.dart';

class VisitedPagesPage extends StatefulWidget {
  const VisitedPagesPage({Key? key}) : super(key: key);

  @override
  _VisitedPagesPageState createState() => _VisitedPagesPageState();
}

class _VisitedPagesPageState extends State<VisitedPagesPage> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                DatabaseHelper.instance.removeALL();
              });
            },
          ),
          appBar: AppBar(
            title: const Text('Visited Pages'),
          ),
          body: FutureBuilder<List<VisitedPage>>(
            future: DatabaseHelper.instance.getPages(),
            builder: (BuildContext context,
                AsyncSnapshot<List<VisitedPage>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              } else {
                return snapshot.data!.isEmpty
                    ? const Center(child: Text('No Pages visited yet.'))
                    : ListView(
                        children: snapshot.data!.map((page) {
                        return Center(
                            child: ListTile(
                          title: Text(page.content),
                          onLongPress: () {
                            setState(() {
                              DatabaseHelper.instance.remove(page.id!);
                            });
                          },
                        ));
                      }).toList());
              }
            },
          ));
    });
  }
}
