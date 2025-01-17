import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project_soe/CComponents/ComponentAppBar.dart';
import 'package:project_soe/CComponents/ComponentBottomNavigation.dart';
import 'package:project_soe/CComponents/ComponentShadowedContainer.dart';
import 'package:project_soe/CComponents/ComponentRoundButton.dart';
import 'package:project_soe/CComponents/ComponentTitle.dart';
import 'package:project_soe/GGlobalParams/Styles.dart';
import 'package:project_soe/VAppHome/ViewUserSign.dart';
import 'package:project_soe/VPersonalPage/ViewPersonal.dart';
import 'package:project_soe/VPracticePage/ViewPractice.dart';
import 'package:project_soe/VClassPage/ViewClass.dart';
import 'package:project_soe/VAppHome/ViewGuide.dart';
import 'package:project_soe/VUnImplemented/ViewUnimplemented.dart';
import 'package:project_soe/s_o_e_icons_icons.dart';

class HomeRecData {
  String label;
  IconData icon;
  String routeName;
  HomeRecData(this.label, this.icon, this.routeName);
}

List<HomeRecData> ListHomeRecData = [
  HomeRecData('课前评测', SOEIcons.edit, ViewUnimplemented.routeName),
  HomeRecData('如何上课', SOEIcons.school, ViewGuide.routeName),
  HomeRecData('重点难点', SOEIcons.person, ViewUnimplemented.routeName),
  HomeRecData('训练题库', SOEIcons.home_lib, ViewPractice.routeName),
];

class ViewAppHome extends StatelessWidget {
  static const String routeName = 'apphome';
  ViewAppHome({super.key});
  Widget _buildRectWidget(int retId, BuildContext context, Function() func) {
    return ComponentRoundButton(
      func: func,
      color: gColorE3EDF7RGBA,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ListHomeRecData[retId].icon,
                color: Color.fromARGB(255, 155, 185, 211),
              ),
              ComponentTitle(
                label: ListHomeRecData[retId].label,
                style: gInfoTextStyle,
              ),
            ],
          ),
        ),
      ),
      height: 137,
      width: 137,
      radius: 32,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComponentAppBar(
        title: ComponentTitle(
          label: '首页',
          style: gTitleStyle,
        ),
      ),
      body: Column(
        children: <Widget>[
          ViewUserSign(),
          Padding(
            padding: EdgeInsets.only(top: 30),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRectWidget(
                0,
                context,
                () => Navigator.of(context)
                    .pushNamed(ViewUnimplemented.routeName),
              ),
              _buildRectWidget(
                1,
                context,
                () => Navigator.of(context).pushNamed(ViewGuide.routeName),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 30),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRectWidget(
                2,
                context,
                () => Navigator.of(context)
                    .pushNamed(ViewUnimplemented.routeName),
              ),
              _buildRectWidget(
                3,
                context,
                () => Navigator.of(context)
                    .pushNamed(ViewUnimplemented.routeName),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar:
          ComponentBottomNavigator(curRouteName: ViewAppHome.routeName),
      backgroundColor: gColorE3EDF7RGBA,
    );
  }
}
