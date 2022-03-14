import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

import '../services/flickr.dart';
import '../widgets/my_bottom_bar.dart';
import '../widgets/nav_drawer/navigation_drawer.dart';

class FlickrTest extends StatefulWidget {
  static const pageRoute = "/flickr";

  FlickrTest({Key? key}) : super(key: key);

  @override
  State<FlickrTest> createState() => _FlickrTestState();
}

class _FlickrTestState extends State<FlickrTest> {
  Future<List<String>>? imageurls;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageurls = FlickrService.getnewImage();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Scaffold(
          drawer: const NavigationDrawer(),
          appBar: AppBar(
            title: Title(color: Colors.black, child: Text("Flickr")),
          ),
          bottomNavigationBar: const MyBottomBar(selectedIndex: 0),
          floatingActionButton: FloatingActionButton(
            child: const Icon(FontAwesomeIcons.redoAlt),
            onPressed: () {
              imageurls = FlickrService.getnewImage();
            },
          ),
          body: FutureBuilder(
            future: imageurls,
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.hasData) {
                List<String> data = snapshot.data!;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Image.network(data[index]);
                  },
                );
              } else {
                return const Center(child: LoadingWidget());
              }
            },
          ),
        ));
  }
}
