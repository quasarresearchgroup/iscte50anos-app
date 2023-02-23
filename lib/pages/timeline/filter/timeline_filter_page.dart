import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_scopes_widget.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_topics_widget.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_filter_result_state.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_state.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_field.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:logger/logger.dart';

class TimelineFilterPage extends StatefulWidget {
  TimelineFilterPage({
    Key? key,
    this.filterParams,
  }) : super(key: key);

  static const String pageRoute = "filter";
  static const ValueKey pageKey = ValueKey(pageRoute);
  final Logger _logger = Logger();

  //final void Function(int) handleEventSelection;
  //final void Function(int) handleYearSelection;

  final TimelineFilterParams? filterParams;

  @override
  State<TimelineFilterPage> createState() => _TimelineFilterPageState();
}

class _TimelineFilterPageState extends State<TimelineFilterPage> {
  // Set<Topic> selectedTopics = {};

  late final TextEditingController searchBarController;
  final double childAspectRatio = 20 / 4;
  final double dividerWidth = 20;
  final double dividerThickness = 2;

  @override
  void initState() {
    searchBarController = TextEditingController();
    super.initState();
    if (widget.filterParams != null) {
      // selectedTopics.addAll(widget.filterParams!.topics);
      searchBarController.text = widget.filterParams!.searchText;
    } /*
    searchBarController.addListener(() {
      filterParams.searchText = searchBarController.text;
    });*/
  }

  int gridCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width > 2000
        ? 4
        : width > 1500
            ? 3
            : width > 1000
                ? 2
                : 1;
  }

  @override
  void dispose() {
    super.dispose();
    searchBarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? titleStyle = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(color: IscteTheme.iscteColor);
    TextStyle? textStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black);
    return Scaffold(
      body: buildBody(
          context: context, titleStyle: titleStyle, textStyle: textStyle),
    );
  }

  Padding buildBody(
      {required BuildContext context,
      TextStyle? titleStyle,
      TextStyle? textStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: [
                buildSearchBar(context: context),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 10,
                  ),
                ),
                //selectedScopesWidget(dividerWidth, dividerThickness),
                //selectedTopicsWidget(dividerWidth, dividerThickness),
                ScopesFilterWidget(
                  titleStyle: titleStyle,
                  textStyle: textStyle,
                  childAspectRatio: childAspectRatio,
                  gridCount: gridCount(context),
                ),
                TopicsFilterWidget(
                  titleStyle: titleStyle,
                  textStyle: textStyle,
                  childAspectRatio: childAspectRatio,
                  gridCount: gridCount(context),
                ),
                //SliverToBoxAdapter(child: divider),
                //SliverToBoxAdapter(child: submitTextButton),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DynamicTextButton(
                  style: IscteTheme.iscteColor,
                  onPressed: () => _submitSelection(context),
                  child:
                      Text(AppLocalizations.of(context)!.timelineSearchButton),
                ),
                const DynamicTextButton(
                  style: IscteTheme.greyColor,
                  onPressed: TimelineState.clearFilter,
                  child: Text(
                    "Clear",
                    // TODO
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //region Topics

  Widget selectedTopicsWidget(
      final double dividerWidth, final double dividerThickness) {
    Widget wrap = ValueListenableBuilder<TimelineFilterParams>(
        valueListenable: TimelineState.currentTimelineFilterParams,
        builder: (context, currentTimelineFilter, child) => Wrap(
              spacing: 5,
              runSpacing: 5,
              alignment: WrapAlignment.start,
              direction: Axis.horizontal,
              children: currentTimelineFilter.topics
                  .map((Topic topic) => Chip(
                        label: Text(topic.title ?? "No Title"),
                        onDeleted: () {
                          currentTimelineFilter.removeTopic(topic);
                        },
                      ))
                  .toList(),
            ));

    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: TimelineState.currentTimelineFilterParams.value.isTopicsEmpty()
            ? null
            : Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.timelineSelectedTopics,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: IscteTheme.iscteColor),
                    ),
                  ),
                ),
                wrap,
                Divider(height: dividerWidth, thickness: dividerThickness),
              ]),
      ),
    );
  }

  //endregion

  //region EventScopes

  Widget selectedScopesWidget(
      final double dividerWidth, final double dividerThickness) {
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: ValueListenableBuilder<TimelineFilterParams>(
            valueListenable: TimelineState.currentTimelineFilterParams,
            builder: (context, currentTimelineFilter, child) =>
                currentTimelineFilter.isScopesEmpty()
                    ? Container()
                    : Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Selected Scopes", //TODO
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: IscteTheme.iscteColor),
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          alignment: WrapAlignment.start,
                          direction: Axis.horizontal,
                          children: currentTimelineFilter.scopes
                              .map((EventScope scope) => Chip(
                                    label: Text(scope.name),
                                    onDeleted: () {
                                      setState(() {
                                        currentTimelineFilter
                                            .removeScope(scope);
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                        Divider(
                            height: dividerWidth, thickness: dividerThickness),
                      ])),
      ),
    );
  }

  //endregion

  Widget buildSearchBar(
      {required BuildContext context, TextStyle? titleStyle}) {
    return SliverAppBar(
      iconTheme:
          Theme.of(context).iconTheme.copyWith(color: IscteTheme.iscteColor),
      actionsIconTheme:
          Theme.of(context).iconTheme.copyWith(color: IscteTheme.iscteColor),
      leading: Hero(
        tag: "searchIcon",
        child: (PlatformService.instance.isIos)
            ? CupertinoButton(
                onPressed: () => _submitSelection(context),
                child: const Icon(CupertinoIcons.search))
            : IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _submitSelection(context),
              ),
      ),
      actions: [
        (PlatformService.instance.isIos)
            ? CupertinoButton(
                onPressed: Navigator.of(context).pop,
                child: const Icon(CupertinoIcons.clear))
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: Navigator.of(context).pop)
      ],
      title: DynamicTextField(
        style: titleStyle,
        controller: searchBarController,
        placeholder: "Pesquise aqui", // TODO
        placeholderStyle: titleStyle,

        //border: InputBorder.none,
      ),
    );
  }

  void _submitSelection(BuildContext context) async {
    TimelineState.operateFilter(
        (params) => params.set(searchText: searchBarController.text));

    TimelineFilterResultState.submitFilter(context);
  }
}