import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/timeline_filter_results_page.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/services/timeline/timeline_topic_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_field.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class TimelineFilterPage extends StatefulWidget {
  TimelineFilterPage({
    Key? key,
    this.filterParams,
  }) : super(key: key);

  static const String pageRoute = "filter";
  static const ValueKey pageKey = ValueKey(pageRoute);
  final Logger _logger = Logger();

  final TimelineFilterParams? filterParams;

  @override
  State<TimelineFilterPage> createState() => _TimelineFilterPageState();
}

class _TimelineFilterPageState extends State<TimelineFilterPage> {
  void handleFilterSubmission(TimelineFilterParams filters, bool showResults) {
    Logger()
        .d("handledFilterSubmission with $filters ; showResults: $showResults");
    if (showResults) {
      Navigator.of(context).pushNamed(TimelineFilterResultsPage.pageRoute,
          arguments: _selectedFilterParams);
    }
    _selectedFilterParams = filters;
  }

  final Future<List<int>> yearsList = TimelineEventService.fetchYearsList();
  final Future<List<Topic>> availableTopics =
      TimelineTopicService.fetchAllTopics();
  final Future<List<EventScope>> availableScopes =
      Future(() => EventScope.values);

  bool advancedSearch = true;
  TimelineFilterParams filterParams =
      TimelineFilterParams(topics: {}, scopes: {}, searchText: "");
  late final TextEditingController searchBarController;

  TimelineFilterParams? _selectedFilterParams;

  @override
  void initState() {
    searchBarController = TextEditingController();
    super.initState();
    if (widget.filterParams != null) {
      filterParams = widget.filterParams!;
      searchBarController.text = widget.filterParams!.searchText;
    }
    filterParams.addListener(() {
      handleFilterSubmission(filterParams, false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchBarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyAppBar(
        leading: const DynamicBackIconButton(),
        trailing: (PlatformService.instance.isIos)
            ? CupertinoButton(
                onPressed: _enableAdvancedSearch,
                child: Icon(
                  advancedSearch
                      ? CupertinoIcons.settings
                      : CupertinoIcons.settings_solid,
                  semanticLabel: AppLocalizations.of(context)!
                      .timelineSearchHintInsideTopic,
                  color: Colors.white,
                ))
            : IconButton(
                tooltip:
                    AppLocalizations.of(context)!.timelineSearchHintInsideTopic,
                onPressed: _enableAdvancedSearch,
                icon: Icon(
                  advancedSearch ? Icons.filter_alt : Icons.filter_alt_outlined,
                  semanticLabel: AppLocalizations.of(context)!
                      .timelineSearchHintInsideTopic,
                )),
        middle: buildSearchBar(context, filterParams.isTopicsEmpty()),
      ),
      body: buildBody(context),
    );
  }

  Padding buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: !advancedSearch
            ? Center(
                child: DynamicTextButton(
                  style: IscteTheme.iscteColor,
                  onPressed: _submitSelection,
                  child:
                      Text(AppLocalizations.of(context)!.timelineSearchButton),
                ),
              )
            : OrientationBuilder(
                builder: (BuildContext context, Orientation orientation) {
                const double dividerWidth = 20;
                const double dividerThickness = 2;
                Widget divider = (orientation == Orientation.landscape)
                    ? const VerticalDivider(
                        width: dividerWidth,
                        thickness: dividerThickness,
                      )
                    : const Divider(
                        height: dividerWidth, thickness: dividerThickness);

                var submitTextButton = DynamicTextButton(
                  style: IscteTheme.iscteColor,
                  onPressed: _submitSelection,
                  child:
                      Text(AppLocalizations.of(context)!.timelineSearchButton),
                );
                int rightProportion = 50;
                return (orientation == Orientation.landscape)
                    ? Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 100 - rightProportion,
                            child: CustomScrollView(
                              scrollDirection: Axis.vertical,
                              slivers: [
                                selectedTopicsWidget(
                                    dividerWidth, dividerThickness),
                                selectedScopesWidget(
                                    dividerWidth, dividerThickness),
                                SliverToBoxAdapter(child: submitTextButton),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            width: dividerWidth,
                            thickness: dividerThickness,
                          ),
                          Flexible(
                            flex: rightProportion,
                            child: CustomScrollView(
                              scrollDirection: Axis.vertical,
                              slivers: [
                                buildAvailableEventScopeHeader(),
                                buildEventScopesCheckBoxList(),
                                buildAvailableTopicsHeader(context),
                                buildTopicsCheckBoxList(),
                              ],
                            ),
                          )
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: CustomScrollView(
                              scrollDirection: Axis.vertical,
                              slivers: [
                                selectedScopesWidget(
                                    dividerWidth, dividerThickness),
                                selectedTopicsWidget(
                                    dividerWidth, dividerThickness),
                                buildAvailableEventScopeHeader(),
                                buildEventScopesCheckBoxList(),
                                buildAvailableTopicsHeader(context),
                                buildTopicsCheckBoxList(),
                                //SliverToBoxAdapter(child: divider),
                                //SliverToBoxAdapter(child: submitTextButton),
                              ],
                            ),
                          ),
                          submitTextButton,
                        ],
                      );
              }),
      ),
    );
  }

  //region Topics
  Widget buildAvailableTopicsHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    AppLocalizations.of(context)!.timelineAvailableTopics)),
            Expanded(
              child: Container(),
            ),
            DynamicTextButton(
              onPressed: _selectAllTopics,
              child: Text(AppLocalizations.of(context)!.timelineSelectAllButton,
                  style: const TextStyle(color: IscteTheme.iscteColor)),
            ),
            DynamicTextButton(
              onPressed: _clearTopicsList,
              child: Text(
                  AppLocalizations.of(context)!.timelineSelectClearButton,
                  style: const TextStyle(color: IscteTheme.iscteColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectedTopicsWidget(
      final double dividerWidth, final double dividerThickness) {
    Widget wrap = Wrap(
      spacing: 5,
      runSpacing: 5,
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      children: filterParams.getTopics
          .map((Topic topic) => Chip(
                label: Text(topic.title ?? ""),
                backgroundColor: IscteTheme.iscteColor,
                onDeleted: () {
                  setState(() {
                    filterParams.removeTopic(topic);
                  });
                },
              ))
          .toList(),
    );
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: filterParams.isTopicsEmpty()
            ? Container()
            : Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        AppLocalizations.of(context)!.timelineSelectedTopics),
                  ),
                ),
                wrap,
                Divider(height: dividerWidth, thickness: dividerThickness),
              ]),
      ),
    );
  }

  Widget buildTopicsCheckBoxList() {
    return FutureBuilder<List<Topic>>(
      future: availableTopics,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Topic> data = snapshot.data!;
          return SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 16 / 4),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return CheckboxListTile(
                    activeColor: IscteTheme.iscteColor,
                    value: filterParams.containsTopic(data[index]),
                    title: SingleChildScrollView(
                      controller: ScrollController(),
                      scrollDirection: Axis.horizontal,
                      child: Text(data[index].title ?? ""),
                    ),
                    onChanged: (bool? bool) {
                      if (bool != null) {
                        if (bool) {
                          setState(() {
                            filterParams.addTopic(data[index]);
                          });
                        } else {
                          setState(() {
                            filterParams.removeTopic(data[index]);
                          });
                        }
                        widget._logger.d(filterParams);
                      }
                    },
                  );
                },
                childCount: data.length,
              ));
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
              child: ErrorWidget(AppLocalizations.of(context)!.generalError));
        } else {
          return const SliverToBoxAdapter(child: LoadingWidget());
        }
      },
    );
  }

  void _selectAllTopics() async {
    List<Topic> allTopics = await availableTopics;
    setState(() {
      filterParams.addAllTopic(allTopics);
    });
  }

  void _clearTopicsList() {
    setState(() {
      filterParams.clearTopics();
    });
  }

  //endregion

  //region EventScopes

  Widget buildAvailableEventScopeHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("Available Scopes...")),
            Expanded(
              child: Container(),
            ),
            DynamicTextButton(
              onPressed: _selectAllScopes,
              child: Text(AppLocalizations.of(context)!.timelineSelectAllButton,
                  style: const TextStyle(color: IscteTheme.iscteColor)),
            ),
            DynamicTextButton(
              onPressed: _clearScopesList,
              child: Text(
                  AppLocalizations.of(context)!.timelineSelectClearButton,
                  style: const TextStyle(color: IscteTheme.iscteColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEventScopesCheckBoxList() {
    return FutureBuilder<List<EventScope>>(
      future: availableScopes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<EventScope> data = snapshot.data!;
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 16 / 4,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return CheckboxListTile(
                  activeColor: IscteTheme.iscteColor,
                  value: filterParams.containsScope(data[index]),
                  title: SingleChildScrollView(
                    controller: ScrollController(),
                    scrollDirection: Axis.horizontal,
                    child: Text(data[index].name ?? ""),
                  ),
                  onChanged: (bool? bool) {
                    if (bool != null) {
                      if (bool) {
                        setState(() {
                          filterParams.addScope(data[index]);
                        });
                      } else {
                        setState(() {
                          filterParams.removeScope(data[index]);
                        });
                      }
                    }
                  },
                );
              },
              childCount: data.length,
              addAutomaticKeepAlives: true,
            ),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
              child: ErrorWidget(AppLocalizations.of(context)!.generalError));
        } else {
          return const SliverToBoxAdapter(child: LoadingWidget());
        }
      },
    );
  }

  Widget selectedScopesWidget(
      final double dividerWidth, final double dividerThickness) {
    Widget wrap = Wrap(
      spacing: 5,
      runSpacing: 5,
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      children: filterParams.getScopes
          .map((EventScope scope) => Chip(
                label: Text(scope.name ?? ""),
                backgroundColor: IscteTheme.iscteColor,
                onDeleted: () {
                  setState(() {
                    filterParams.removeScope(scope);
                  });
                },
              ))
          .toList(),
    );
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: filterParams.isScopesEmpty()
            ? Container()
            : Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Selected Scopes"),
                  ),
                ),
                wrap,
                Divider(height: dividerWidth, thickness: dividerThickness),
              ]),
      ),
    );
  }

  Future<void> _selectAllScopes() async {
    List<EventScope> allScopes = await availableScopes;
    setState(() {
      filterParams.addAllScope(allScopes);
    });
  }

  Future<void> _clearScopesList() async {
    setState(() {
      filterParams.clearScopes();
    });
  }

  //endregion

  Widget buildSearchBar(BuildContext context, bool isEmptySelectedTopics) {
    return Center(
      child: DynamicTextField(
        style: const TextStyle(color: Colors.white),
        controller: searchBarController,
        placeholderStyle: const TextStyle(color: Colors.white70),
        prefix: (PlatformService.instance.isIos)
            ? CupertinoButton(
                onPressed: _submitSelection,
                child: const Icon(
                  CupertinoIcons.search,
                  color: Colors.white,
                ))
            : IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: _submitSelection,
              ),
        suffix: (PlatformService.instance.isIos)
            ? CupertinoButton(
                onPressed: searchBarController.clear,
                child: const Icon(
                  CupertinoIcons.clear,
                  color: Colors.white,
                ))
            : IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: searchBarController.clear),
        placeholder: !advancedSearch
            ? AppLocalizations.of(context)!.timelineSearchHint
            : AppLocalizations.of(context)!.timelineSearchHintInsideTopic,
        //border: InputBorder.none,
      ),
    );
  }

  void _enableAdvancedSearch() {
    setState(() {
      advancedSearch = !advancedSearch;
      if (!advancedSearch) {
        filterParams.clearTopics();
      }
    });
    widget._logger.d("advancedSearch: $advancedSearch");
  }

  void _submitSelection() async {
    filterParams.searchText = searchBarController.text;
    handleFilterSubmission(filterParams, true);
  }
}
