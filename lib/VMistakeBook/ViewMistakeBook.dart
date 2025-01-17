import 'package:flutter/material.dart';
import 'package:project_soe/CComponents/ComponentAppBar.dart';
import 'package:project_soe/CComponents/ComponentBottomNavigation.dart';
import 'package:project_soe/CComponents/ComponentRoundButton.dart';
import 'package:project_soe/CComponents/ComponentSubtitle.dart';
import 'package:project_soe/CComponents/ComponentTitle.dart';
import 'package:project_soe/GGlobalParams/Styles.dart';
import 'package:project_soe/VMistakeBook/DataMistake.dart';
import 'package:project_soe/VMistakeBook/ViewMistakeDetail.dart';

class ViewMistakeBook extends StatelessWidget {
  static const String routeName = 'mistake';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ViewMistakeBookBody(),
      backgroundColor: gColorE3EDF7RGBA,
      bottomNavigationBar: ComponentBottomNavigator(
        curRouteName: routeName,
      ),
      appBar: ComponentAppBar(
        hasBackButton: true,
        title: ComponentTitle(
          label: '错题本',
          style: gTitleStyle,
        ),
      ),
    );
  }
}

class _ViewMistakeBookBody extends StatelessWidget {
  Widget _buildItem(BuildContext context, mistakeItem) => ListTile(
        leading: Text(mistakeItem.mistakeTypeName, style: gTitleStyle),
        title: ComponentCircleButton(
          func: () => Navigator.of(context).pushNamed(
              ViewMistakeDetail.routeName,
              arguments: <int>[0, mistakeItem.mistakeTypeCode]),
          color: gColor6E81A0RGBA,
          child: ComponentSubtitle(label: '查询一周', style: gSubtitleStyle),
          size: 25,
        ),
        trailing: ComponentCircleButton(
          func: () => Navigator.of(context).pushNamed(
              ViewMistakeDetail.routeName,
              arguments: <int>[1, mistakeItem.mistakeTypeCode]),
          color: gColor6E81A0RGBA,
          child: ComponentSubtitle(label: '查询全部', style: gSubtitleStyle),
          size: 25,
        ),
      );

  Widget _buildBodyImpl(BuildContext context, DataMistakeBook mistakeBook) {
    List<Widget> wrongList = List.empty(growable: true);
    for (DataMistakeItem mistakeItem in mistakeBook.mistakeItemList) {
      wrongList.add(_buildItem(context, mistakeItem));
    }
    final listView = ListView(
      children: wrongList,
    );
    return listView;
  }

  @override
  Widget build(BuildContext buildContext) => FutureBuilder<DataMistakeBook>(
        future: getGetDataMistakeBook(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildBodyImpl(context, snapshot.data!);
          } else {
            return CircularProgressIndicator();
          }
        },
      );
}
