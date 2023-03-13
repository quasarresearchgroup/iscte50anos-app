import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/timeline/list_view/year_timeline_list_tile.dart';
import 'package:iscte_spots/pages/timeline/web_scroll_behaviour.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class YearTimeline extends StatefulWidget {
  const YearTimeline({
    Key? key,
    this.hoveredYearIndexNotifier,
    required this.currentYearsListValue,
    required this.currentYearNotifier,
    required this.changeYearCallback,
    required this.isFilter,
  }) : super(key: key);

  final ValueNotifier<int?>? hoveredYearIndexNotifier;
  final Future<List<int>> currentYearsListValue;
  final bool isFilter;
  final ValueNotifier<int?> currentYearNotifier;

  /// Callback to use for click event for each tile in the list view
  final void Function(int year)? changeYearCallback;

  @override
  State<YearTimeline> createState() => _YearTimelineState();
}

class _YearTimelineState extends State<YearTimeline> {
  final ItemScrollController itemController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.hoveredYearIndexNotifier != null) {
      widget.hoveredYearIndexNotifier!.addListener(
        () {
          if (widget.hoveredYearIndexNotifier!.value != null) {
            itemController.scrollTo(
                index: widget.hoveredYearIndexNotifier!.value!,
                duration: const Duration(milliseconds: 300));
          }
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hoveredYearIndexNotifier != null) {
      return ValueListenableBuilder<int?>(
        valueListenable: widget.hoveredYearIndexNotifier!,
        builder: (context, int? hoverYearIndex, _) {
          return YearTimelineListView(
            itemController: itemController,
            hoverYearIndex: hoverYearIndex,
            currentYearNotifier: widget.currentYearNotifier,
            yearsListFuture: widget.currentYearsListValue,
            changeYearCallback: widget.changeYearCallback,
          );
        },
      );
    } else {
      return YearTimelineListView(
        yearsListFuture: widget.currentYearsListValue,
        itemController: itemController,
        changeYearCallback: widget.changeYearCallback,
        currentYearNotifier: widget.currentYearNotifier,
      );
    }
  }
}

class YearTimelineListView extends StatelessWidget {
  const YearTimelineListView({
    Key? key,
    this.hoverYearIndex,
    required this.currentYearNotifier,
    required this.itemController,
    required this.yearsListFuture,
    this.changeYearCallback,
  }) : super(key: key);

  final ItemScrollController itemController;
  final int? hoverYearIndex;
  final ValueNotifier<int?> currentYearNotifier;
  final Future<List<int>> yearsListFuture;
  final Function(int year)? changeYearCallback;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
        valueListenable: currentYearNotifier,
        builder: (context, int? currentYear, _) {
          return FutureBuilder<List<int>>(
            future: yearsListFuture,
            builder: (context, yearsListSnapshot) {
              if (yearsListSnapshot.connectionState == ConnectionState.done &&
                  yearsListSnapshot.hasData) {
                return ScrollConfiguration(
                  behavior: WebScrollBehaviour(),
                  child: ScrollablePositionedList.builder(
                    initialScrollIndex: currentYear != null
                        ? yearsListSnapshot.data!.contains(currentYear)
                            ? yearsListSnapshot.data!.indexOf(currentYear)
                            : yearsListSnapshot.data!.length - 1
                        : yearsListSnapshot.data!.length - 1,
                    itemScrollController: itemController,
                    scrollDirection: Axis.horizontal,
                    itemCount: yearsListSnapshot.data!.length,
                    shrinkWrap: false,
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) =>
                        YearTimelineTile(
                      year: yearsListSnapshot.data![index],
                      isSelected: currentYear == yearsListSnapshot.data![index],
                      isHover: hoverYearIndex == index,
                      isFirst: index == 0,
                      isLast: index == yearsListSnapshot.data!.length - 1,
                      onTap: changeYearCallback,
                    ),
                  ),
                );
              } else if (yearsListSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const LoadingWidget();
              } else if (yearsListSnapshot.hasError) {
                return DynamicErrorWidget(
                  display: yearsListSnapshot.error.toString(),
                );
              } else {
                return const LoadingWidget();
              }
            },
          );
        });
  }
}
