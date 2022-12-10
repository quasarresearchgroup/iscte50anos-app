import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/timeline/list_view/year_timeline_list_tile.dart';
import 'package:iscte_spots/pages/timeline/web_scroll_behaviour.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class YearTimelineListView extends StatefulWidget {
  const YearTimelineListView({
    Key? key,
    required this.changeYearFunction,
    required this.yearsList,
    required this.currentYear,
    required this.selectedYearIndex,
  }) : super(key: key);

  final Function(int) changeYearFunction;
  final List<int> yearsList;
  final ValueNotifier<int?> currentYear;
  final ValueNotifier<int?> selectedYearIndex;

  @override
  State<YearTimelineListView> createState() => _YearTimelineListViewState();
}

class _YearTimelineListViewState extends State<YearTimelineListView> {
  final ItemScrollController itemController = ItemScrollController();
  final List<Widget> yearsList = [];

  @override
  void initState() {
    super.initState();
    widget.selectedYearIndex.addListener(() {
      if (widget.selectedYearIndex.value != null) {
        itemController.scrollTo(
            index: widget.selectedYearIndex.value!,
            duration: const Duration(milliseconds: 300));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
        valueListenable: widget.selectedYearIndex,
        builder: (context, value, _) {
          return ScrollConfiguration(
            behavior: WebScrollBehaviour(),
            child: ScrollablePositionedList.builder(
                initialScrollIndex: widget.currentYear.value != null
                    ? widget.yearsList.indexOf(widget.currentYear.value!)
                    : widget.yearsList.length - 1,
                itemScrollController: itemController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.yearsList.length,
                shrinkWrap: false,
                itemBuilder: (
                  BuildContext context,
                  int index,
                ) =>
                    YearTimelineTile(
                      // key: itemKey,
                      changeYearFunction: widget.changeYearFunction,
                      year: widget.yearsList[index],
                      isSelected:
                          widget.currentYear.value == widget.yearsList[index],
                      isHover: value == index,
                      isFirst: index == 0,
                      isLast: index == widget.yearsList.length - 1,
                    )),
          );
        });
  }
}
