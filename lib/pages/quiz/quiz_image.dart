import 'package:flutter/material.dart';
import 'package:iscte_spots/services/quiz/quiz_service.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class QuizImage extends StatefulWidget {
  final String flickrUrl;
  final void Function() onLoadCallback;
  final void Function() onErrorCallback;

  const QuizImage({
    Key? key,
    required this.flickrUrl,
    required this.onLoadCallback,
    required this.onErrorCallback,
  }) : super(key: key);

  @override
  State<QuizImage> createState() => _QuizImageState();
}

class _QuizImageState extends State<QuizImage> {
  late Future<String> imageUrl;

  @override
  void initState() {
    super.initState();
    imageUrl = QuizService.getPhotoURLfromQuizFlickrURL(widget.flickrUrl);
    imageUrl.then(
      (String value) => widget.onLoadCallback(),
      onError: (error) => widget.onErrorCallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: imageUrl,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: Colors.white,
              child: PinchZoom(
                child: Image.network(
                  snapshot.data.toString(),
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    return child;
                  },
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator.adaptive(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return DynamicErrorWidget.networkError(context: context);
          } else {
            return const Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }
        });
  }
}
