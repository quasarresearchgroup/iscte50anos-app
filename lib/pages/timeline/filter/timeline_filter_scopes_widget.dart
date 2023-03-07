import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_state.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class ScopesFilterWidget extends StatelessWidget {
  ScopesFilterWidget({
    Key? key,
    this.titleStyle,
    this.textStyle,
    required this.gridCount,
    required this.childAspectRatio,
    required this.eventScopes,
  }) : super(key: key);

  final int gridCount;
  final double childAspectRatio;
  final List<EventScope> eventScopes;
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
            .titleLarge
            ?.copyWith(color: IscteTheme.iscteColor);
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          buildAvailableEventScopeHeader(),
          buildEventScopesCheckBoxList(eventScopes),
        ],
      ),
    );
  }

  Future<void> _selectAllScopesCallback() async {
    List<EventScope> allScopes =
        await TimelineState.availableScopesFuture.value;
    TimelineState.operateFilter((params) => params.addAllScope(allScopes));
  }

  Future<void> _clearScopesListCallback() async {
    TimelineState.operateFilter((params) => params.clearScopes());
  }

  Widget buildAvailableEventScopeHeader() {
    return Builder(builder: (context) {
      Text text = Text(
        AppLocalizations.of(context)!.timelineAvailableScopes,
        style: titleStyle,
      );

      DynamicTextButton selectAllBtn = DynamicTextButton(
        style: IscteTheme.greyColor,
        onPressed: _selectAllScopesCallback,
        child: Text(AppLocalizations.of(context)!.timelineSelectAllButton,
            style: titleStyle),
      );

      DynamicTextButton clearAllBtn = DynamicTextButton(
        style: IscteTheme.greyColor,
        onPressed: _clearScopesListCallback,
        child: Text(AppLocalizations.of(context)!.timelineSelectClearButton,
            style: titleStyle),
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

  Widget buildEventScopesCheckBoxList(List<EventScope> scopes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scopes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCount,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        return ValueListenableBuilder<TimelineFilterParams>(
          valueListenable: TimelineState.currentTimelineFilterParams,
          builder: (context, currentTimelineFilter, child) => CheckboxListTile(
            activeColor: IscteTheme.iscteColor,
            value: currentTimelineFilter.containsScope(scopes[index]),
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                scopes[index].name,
                style: textStyle,
              ),
            ),
            onChanged: (bool? bool) {
              if (bool != null) {
                if (bool) {
                  TimelineState.operateFilter(
                      (params) => params.addScope(scopes[index]));
                } else {
                  TimelineState.operateFilter(
                      (params) => params.removeScope(scopes[index]));
                }
              }
            },
          ),
        );
      },
    );
  }
}
