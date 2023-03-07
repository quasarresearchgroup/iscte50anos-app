import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_state.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class TopicsFilterWidget extends StatelessWidget {
  TopicsFilterWidget({
    Key? key,
    this.titleStyle,
    this.textStyle,
    required this.childAspectRatio,
    required this.gridCount,
    required this.topics,
  }) : super(key: key);

  final int gridCount;
  final List<Topic> topics;
  final double childAspectRatio;
  TextStyle? titleStyle;
  TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    titleStyle = titleStyle ??
        Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: IscteTheme.iscteColor);
    textStyle = textStyle ??
        Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: IscteTheme.iscteColor);
    return SliverList(
      delegate: SliverChildListDelegate([
        buildAvailableTopicsHeader(),
        buildTopicsCheckBoxList(topics),
      ]),
    );
  }

  Widget buildAvailableTopicsHeader() {
    return Builder(builder: (context) {
      var text = Text(
        AppLocalizations.of(context)!.timelineAvailableTopics,
        style: titleStyle,
      );
      var selectAllBtn = DynamicTextButton(
        style: IscteTheme.greyColor,
        onPressed: _selectAllTopics,
        child: Text(AppLocalizations.of(context)!.timelineSelectAllButton,
            style: titleStyle),
      );
      var clearAllBtn = DynamicTextButton(
        style: IscteTheme.greyColor,
        onPressed: _clearTopicsList,
        child: Text(
          AppLocalizations.of(context)!.timelineSelectClearButton,
          style: titleStyle,
        ),
      );

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          runSpacing: 10,
          spacing: 10,
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: [text, selectAllBtn, clearAllBtn],
        ),
      );
    });
  }

  void _selectAllTopics() async {
    List<Topic> allTopics = await TimelineState.availableTopicsFuture.value;
    TimelineState.operateFilter((params) => params.addAllTopic(allTopics));
  }

  void _clearTopicsList() {
    TimelineState.operateFilter((params) => params.clearTopics());
  }

  Widget buildTopicsCheckBoxList(List<Topic> data) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCount, childAspectRatio: childAspectRatio),
      itemBuilder: (context, index) {
        return ValueListenableBuilder<TimelineFilterParams>(
          valueListenable: TimelineState.currentTimelineFilterParams,
          builder: (context, currentTimelineFilter, child) => CheckboxListTile(
            //activeColor: IscteTheme.iscteColor,
            value: TimelineState.currentTimelineFilterParams.value
                .containsTopic(data[index]),
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                data[index].title ?? "No Title", //TODO
                style: textStyle,
              ),
            ),
            onChanged: (bool? bool) {
              if (bool != null) {
                if (bool) {
                  TimelineState.operateFilter(
                      (params) => params.addTopic(data[index]));
                } else {
                  TimelineState.operateFilter(
                      (params) => params.removeTopic(data[index]));
                }
              }
            },
          ),
        );
      },
    );
  }
}
