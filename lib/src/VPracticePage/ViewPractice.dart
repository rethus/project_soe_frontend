import 'package:flutter/material.dart';
import 'package:project_soe/src/CComponents/ComponentRoundButton.dart';

import 'package:project_soe/src/CComponents/ComponentSubtitle.dart';
import 'package:project_soe/src/CComponents/ComponentTitle.dart';
import 'package:project_soe/src/GGlobalParams/Styles.dart';
import 'package:project_soe/src/VAppHome/ViewAppHome.dart';
import 'package:project_soe/src/VAuthorition/ViewLogin.dart';
import 'package:project_soe/src/VExam/DataQuestion.dart';
import 'package:project_soe/src/VPracticePage/DataPractice.dart';
import 'package:project_soe/src/VExam/ViewExam.dart';
import 'package:project_soe/src/VAuthorition/LogicAuthorition.dart';

// FIXME 22.12.4 Temp
List<String> tempTitles = [
  '文章标题1',
  '文章标题2',
  '文章标题3',
  '文章标题4',
  '文章标题5',
  '文章标题6',
];
// FIXME 22.12.4 Temp
List<String> tempTitles1 = [
  '看图说话1',
  '看图说话2',
  '看图说话3',
  '看图说话4',
  '看图说话5',
  '看图说话6',
];
// FIXME 22.12.4 Temp
List<int> tempCount2 = [212, 39, 4];
List<String> tempTitles2 = [
  '声母练习',
  '韵母练习',
  '声调练习',
];
// FIXME 22.12.4 Temp
List<String> tempTitle3 = [
  '专项练习1',
  '专项练习2',
  '专项练习3',
];

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});
  static const String routeName = 'practice';

  // Widget _buildSpecificText() {
  //   return Padding(
  //     padding: EdgeInsets.only(top: 25.0),
  //     child: Center(
  //       child: Wrap(
  //         children: [
  //           Center(
  //             child: Text('您还没有测试结果, 点击进入测试', style: gSubtitleStyle),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.only(top: 15.0),
  //             child: Center(
  //               child: ElevatedButton(
  //                 onPressed: () {},
  //                 child: Text('点击进入测试'),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildDoubleWordListChild0(String title, int count) {
  //   return Padding(
  //     padding: EdgeInsets.only(top: 2.0, bottom: 2.0, left: 8.0, right: 8.0),
  //     child: ListTile(
  //       title: Text(
  //         title,
  //         style: gPracticePageListitemStyle,
  //       ),
  //       trailing: Text('$count个题目', style: gPracticePageListitemStyle),
  //     ),
  //   );
  // }

  // Widget _buildDoubleWordSubtitle(String title) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: EdgeInsets.only(left: 12.0, top: 12.0),
  //         child: Text(
  //           title,
  //           style: gSubtitleStyle,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildDoubleWordRowChild0(String label) {
  //   return Column(
  //     children: [
  //       Padding(
  //           padding: EdgeInsets.all(18.0),
  //           child: IconButton(
  //             icon: Icon(
  //               Icons.text_format_outlined,
  //               color: Colors.black87,
  //             ),
  //             onPressed: () {},
  //           )),
  //       Text(
  //         label,
  //         style: gPracticePageListitemStyle,
  //       ),
  //     ],
  //   );
  // }

  List<Widget> _buildPracticeButton(BuildContext context, DataPractice data,
      {bool loggedIn = true}) {
    return [
      Container(
        child: ComponentSubtitle(
          label: data.title,
          style: gSubtitleStyle0,
        ),
      ),
      Container(
        child: Text(
          data.desc,
          style: gSubtitleStyle,
        ),
      ),
      TextButton(
          onPressed: loggedIn
              ? () => Navigator.pushNamed(
                    context,
                    ViewExam.routeName,
                    arguments:
                        ArgsViewExam(data.id, '作业', ViewAppHome.routeName),
                  )
              : () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Container(
                        height: 64.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // CircularProgressIndicator(),
                            Column(
                              children: [
                                ComponentTitle(
                                  label: "登录账号以解锁更多内容.",
                                  style: gInfoTextStyle,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: ComponentRoundButton(
                                    func: () => Navigator.of(context)
                                        .pushReplacementNamed(
                                            ViewLogin.routeName),
                                    color: gColorE1EBF5RGBA,
                                    child: ComponentTitle(
                                      label: '点击登录',
                                      style: gInfoTextStyle,
                                    ),
                                    height: 32.0,
                                    width: 64.0,
                                    radius: 5.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          child: Text(
            '进入作业',
            style: gInfoTextStyle,
          )),
    ];
  }

  Widget _buildViewPracticePageImpl(
      BuildContext context, DataPracticePage dataPage) {
    List<Widget> children = List.empty(growable: true);
    // const ComponentSubtitle(label: '声韵调练习'),
    // _buildDoubleWordListChild0(tempTitles2[0], tempCount2[0]),
    // _buildDoubleWordListChild0(tempTitles2[1], tempCount2[1]),
    // _buildDoubleWordListChild0(tempTitles2[2], tempCount2[2]),
    // const ComponentSubtitle(label: '专项训练'),
    // Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    // children: [
    // _buildDoubleWordRowChild0(tempTitle3[0]),
    // _buildDoubleWordRowChild0(tempTitle3[1]),
    // _buildDoubleWordRowChild0(tempTitle3[2]),
    // ],
    // ),
    // const ComponentSubtitle(label: '个性化训练'),
    // ];
    if (!dataPage.dataList.isEmpty) {
      final loggedIn = AuthritionState.get().hasToken();
      if (loggedIn) {
        for (final item in dataPage.dataList) {
          children.addAll(_buildPracticeButton(context, item));
        }
      } else {
        children.addAll(_buildPracticeButton(context, dataPage.dataList[0]));
        for (int iter = 1; iter < dataPage.dataList.length; ++iter) {
          children.addAll(
            _buildPracticeButton(
              context,
              dataPage.dataList[iter],
              loggedIn: false,
            ),
          );
        }
      }
    }
    var _listView = ListView(children: children);
    return Scaffold(
      backgroundColor: gColorE3EDF7RGBA,
      body: _listView,
    );
  }

  // Widget _buildArticlePage() {
  //   final _listView = ListView.builder(
  //     itemCount: tempTitles.length,
  //     itemBuilder: (context, index) => ListTile(
  //       title: Padding(
  //         padding: EdgeInsets.all(6.0),
  //         child: TextButton(
  //           child: Text(tempTitles[index]),
  //           style: gPracticePageArticleButtonStyle,
  //           onPressed: () {
  //             // FIXME 22.12.4 实现点击函数.
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  //   return _listView;
  // }

  // Widget _buildSpeakingPage() {
  //   final _listView = ListView.builder(
  //     itemCount: tempTitles1.length,
  //     itemBuilder: (context, index) => ListTile(
  //       title: Padding(
  //         padding: EdgeInsets.all(6.0),
  //         child: TextButton(
  //           child: Text(tempTitles1[index]),
  //           style: gPracticePageSpeakingButtonStyle,
  //           onPressed: () {
  //             // FIXME 22.12.4 实现点击函数.
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  //   return _listView;
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataPracticePage>(
        future: postGetDataPracticePage(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildViewPracticePageImpl(context, snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
    // DefaultTabController(
    //   length: 3,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       bottom: const TabBar(
    //         tabs: [
    //           Tab(child: Text('练习', style: gPracticePageTabStyle)),
    //           Tab(child: Text('短文阅读', style: gPracticePageTabStyle)),
    //           Tab(child: Text('看图说话', style: gPracticePageTabStyle))
    //         ],
    //       ),
    //     ),
    //     body: TabBarView(children: [
    //       // _buildSingleWordPage(),
    //       _buildViewPracticePageImpl(context),
    //       _buildArticlePage(),
    //       _buildSpeakingPage(),
    //     ]),
    //   ),
    // );
  }
}
