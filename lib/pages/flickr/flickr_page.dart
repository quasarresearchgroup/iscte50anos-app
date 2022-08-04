import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/flickr/flickr_photoset.dart';
import 'package:iscte_spots/pages/flickr/flickr_album_page.dart';
import 'package:iscte_spots/services/flickr/flickr_iscte_album_service.dart';
import 'package:iscte_spots/services/flickr/flickr_service.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:iscte_spots/widgets/util/overlays.dart';
import 'package:logger/logger.dart';

class FlickrPage extends StatefulWidget {
  static const pageRoute = "/flickr";
  final Logger _logger = Logger();
  final FlickrIscteAlbumService flickrService = FlickrIscteAlbumService();
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final int fetchThreshHold = 1000;

  FlickrPage({Key? key}) : super(key: key);

  @override
  State<FlickrPage> createState() => _FlickrPageState();
}

class _FlickrPageState extends State<FlickrPage> {
  List<FlickrPhotoset> fetchedPhotosets = [];
  late StreamSubscription<FlickrPhotoset> _streamSubscription;

  bool networkError = false;
  bool fetching = false;
  bool hasData = false;
  int activePage = 0;
  int lastFetch = 0;

  bool noMoreData = false;

  @override
  void initState() {
    super.initState();
    fetchMorePhotosets();
    widget._pageController.addListener(() {
      if (!fetching &&
          widget._pageController.page != null &&
          fetchedPhotosets.length - 10 <= widget._pageController.page!) {
        widget._logger.d("Should Fetch more photosets");
        fetchMorePhotosets();
      }
    });
    _streamSubscription =
        widget.flickrService.stream.listen((FlickrPhotoset event) {
      setState(() {
        if (!fetchedPhotosets.contains(event)) {
          fetchedPhotosets.add(event);
        } else {
          widget._logger.d("duplicated album entry: $event");
        }
      });
    }, onError: (error) {
      widget._logger.e(error);
      showNetworkErrorOverlay(context, widget._logger);
      noMoreData = error == FlickrService.noDataError;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  void fetchMorePhotosets() async {
    int millisecondsSinceEpoch2 = DateTime.now().millisecondsSinceEpoch;
    if (millisecondsSinceEpoch2 - lastFetch >= widget.fetchThreshHold) {
      try {
        setState(() {
          fetching = true;
        });
        widget._logger.d("fetching more data");
        lastFetch = millisecondsSinceEpoch2;
        await widget.flickrService.fetch();
        networkError = false;
      } on SocketException catch (e) {
        widget._logger.e(e);
        showNetworkErrorOverlay(context, widget._logger);
        networkError = true;
      } finally {
        setState(() {
          fetching = false;
        });
      }
    } else {
      widget._logger.d("wait a bit before fetching againg");
    }
  }

  @override
  Widget build(BuildContext context) {
    hasData = fetchedPhotosets.isNotEmpty;
    return Scaffold(
        appBar: MyAppBar(
          title: AppLocalizations.of(context)!.flickrScreen,
          leading: const DynamicBackIconButton(),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                  child: Text(
                "${activePage + 1} / ${fetchedPhotosets.length}",
                textScaleFactor: 1.25,
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: fetching
                    ? const LoadingWidget()
                    : networkError
                        ? const Icon(Icons.signal_wifi_connected_no_internet_4)
                        : PlatformService.instance.isIos
                            ? const Icon(CupertinoIcons.check_mark)
                            : const Icon(Icons.check),
              ),
            ),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          child: const FaIcon(FontAwesomeIcons.rotateRight),
          onPressed: () {
            fetchMorePhotosets();
          },
        ),
        body: !hasData
            ? SizedBox.expand(
                child: noMoreData
                    ? Center(
                        child:
                            Text(AppLocalizations.of(context)!.noMoreDataError))
                    : const LoadingWidget())
            : LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SizedBox(
                    height: constraints.maxHeight * 0.95,
                    child: PageView.builder(
                      controller: widget._pageController,
                      itemCount: fetchedPhotosets.length + 1,
                      onPageChanged: (int page) {
                        setState(() {
                          activePage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        return index == fetchedPhotosets.length
                            ? const LoadingWidget()
                            : FlickrCard(
                                isActivePage: activePage == index,
                                indexedPhotoset: fetchedPhotosets[index],
                                constraints: constraints,
                              );
                      },
                    ),
                  );
                },
              ));
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
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: indexedPhotoset.primaryphotoURL!,
                fit: BoxFit.fitHeight,
              ),
            ),
          )
        : const FaIcon(FontAwesomeIcons.flickr);

    final double margin = isActivePage ? 10 : 20;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FlickAlbumPage(album: indexedPhotoset)),
        );
      },
      child: AnimatedContainer(
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
      ),
    );
  }
}
