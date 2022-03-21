import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/flickr_photoset.dart';
import 'package:iscte_spots/services/flickr_iscte_album_service.dart';
import 'package:logger/logger.dart';

import '../widgets/my_bottom_bar.dart';
import '../widgets/nav_drawer/navigation_drawer.dart';
import '../widgets/util/loading.dart';

class FlickrTest extends StatefulWidget {
  static const pageRoute = "/flickr";
  final Logger _logger = Logger();
  FlickrTest({Key? key}) : super(key: key);

  @override
  State<FlickrTest> createState() => _FlickrTestState();
}

class _FlickrTestState extends State<FlickrTest> {
  final FlickrIscteAlbumService flickrService = FlickrIscteAlbumService();
  final PageController _pageController = PageController(viewportFraction: 0.8);
  List<FlickrPhotoset>? fetchedPhotosets;

  int activePage = 0;

  @override
  void initState() {
    super.initState();
    fetchMorePhotosets();
    _pageController.addListener(() {
      if (fetchedPhotosets != null &&
          fetchedPhotosets!.length - 2 == _pageController.page) {
        widget._logger.d("Should Fetch more photosets");
        fetchMorePhotosets();
      }
    });
  }

  void fetchMorePhotosets() async {
    widget._logger.d("fetching more");
    flickrService.fetch();
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
            title: Title(color: Colors.black, child: const Text("Flickr")),
          ),
          bottomNavigationBar: const MyBottomBar(selectedIndex: 0),
          floatingActionButton: FloatingActionButton(
            child: const Icon(FontAwesomeIcons.redoAlt),
            onPressed: () {
              fetchMorePhotosets();
            },
          ),
          body: StreamBuilder<List<FlickrPhotoset>>(
            stream: flickrService.stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<FlickrPhotoset>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget();
              } else if (snapshot.connectionState == ConnectionState.done) {
                return const Text('done');
              } else if (snapshot.hasError) {
                return const Text('Error!');
              } else if (snapshot.hasData) {
                fetchedPhotosets = snapshot.data!;
                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Column(
                      children: [
                        SizedBox(
                            height: constraints.maxHeight * 0.05,
                            child: Center(
                                child: Text(
                                    "${activePage + 1} / ${fetchedPhotosets!.length}"))),
                        SizedBox(
                          height: constraints.maxHeight * 0.95,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: fetchedPhotosets!.length,
                            onPageChanged: (int page) {
                              setState(() {
                                activePage = page;
                              });
                            },
                            itemBuilder: (context, index) {
                              return FlickrCard(
                                isActivePage: activePage == index,
                                indexedPhotoset: fetchedPhotosets![index],
                                constraints: constraints,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return const LoadingWidget();
              }
            },
          )),
    );
  }
}

class FlickrCard extends StatelessWidget {
  const FlickrCard({
    Key? key,
    required this.indexedPhotoset,
    required this.constraints,
    required this.isActivePage,
  }) : super(key: key);

  final bool isActivePage;
  final FlickrPhotoset indexedPhotoset;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget = indexedPhotoset.primaryphotoURL != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              indexedPhotoset.primaryphotoURL!,
              fit: BoxFit.fitHeight,
            ),
          )
        : const Icon(FontAwesomeIcons.flickr);

    final double margin = isActivePage ? 0 : 10;

    return AnimatedContainer(
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
      ),
      //padding: const EdgeInsets.all(10),
      margin: EdgeInsets.all(margin),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      child: Column(
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: imageWidget),
          Expanded(
            child: SizedBox(
              width:
                  //MediaQuery.of(context).size.width * 0.7,
                  constraints.maxWidth * 0.7,
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      indexedPhotoset.title,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.5,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ListTile(
                    title: Text(
                      indexedPhotoset.description,
                      softWrap: true,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
