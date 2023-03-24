// TODO 11.2 实现此类.
import 'package:flutter/material.dart';
import 'package:project_soe/src/LAuthorition/login_screen.dart';
import 'package:project_soe/src/LAuthorition/authorition.dart';
import 'package:project_soe/src/PPersonalPage/personal_data.dart';
import 'package:project_soe/src/data/styles.dart';
import 'package:project_soe/src/CComponents/subtitle.dart';

// FIXME 22.12.7 temp
class PersonalRecData {
  String label;
  IconData icon;
  Function()? onPressed;
  PersonalRecData(this.label, this.icon, this.onPressed);
}

// FIXME 22.12.7 temp
List<PersonalRecData> personalRecDatasFirst = [
  PersonalRecData('快速入口1', Icons.book, null),
  PersonalRecData('快速入口2', Icons.book, null),
  PersonalRecData('快速入口3', Icons.book, null),
];
List<PersonalRecData> personalRecDatasSecond = [
  PersonalRecData('快速入口4', Icons.book, null),
  PersonalRecData('快速入口5', Icons.book, null),
  PersonalRecData('快速入口6', Icons.book, null),
];

class PersonalPage extends StatelessWidget {
  const PersonalPage({super.key});
  static const String routeName = 'personal';

  Widget _buildRecWidget(List<PersonalRecData> datalist) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: datalist
          .map(
            (data) => Column(
              children: [
                Padding(
                    padding: EdgeInsets.all(18.0),
                    child: IconButton(
                      icon: Icon(
                        data.icon,
                        color: Colors.black87,
                      ),
                      onPressed: data.onPressed,
                    )),
                Text(
                  data.label,
                  style: gClassPageListitemStyle,
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  bool _hasToken() => AuthritionState.get().hasToken();
  // FIXME 22.12.8 测试用, 总返回true
  // bool _hasToken() => true;

  Widget _buildDetailLine(List<String> details, List<String> labels) {
    List<Widget> chi = [];
    int len = details.length;
    for (int i = 0; i < len; ++i) {
      chi.add(Padding(
        padding: EdgeInsets.only(left: 12.0, right: 12.0),
        child: Text(
          details[i],
          style: gPersonalPageDetailStyle,
        ),
      ));
      chi.add(Padding(
        padding: EdgeInsets.only(left: 12.0, right: 12.0),
        child: Text(
          labels[i],
          style: gPersonalPageLabelStyle,
        ),
      ));
    }
    return Container(
      height: 32.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: chi,
      ),
    );
  }

  Widget _buildDetailsPanel(PersonalData personalData) {
    return Column(
      children: [
        Container(
          height: 120.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // FIXME 临时头像
              Icon(
                Icons.person,
                size: 64.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(personalData.nickName!,
                      style: gPersonalPageNicknameStyle),
                  Text(
                    '个性签名:${personalData.sign!}',
                    style: gPersonalPageLabelStyle,
                  )
                ],
              ),
            ],
          ),
        ),
        const Subtitle(label: '详细信息'),
        _buildDetailLine(['电话号码'], [personalData.phone!]),
        _buildDetailLine(['邮箱'], [personalData.email!]),
        _buildDetailLine([
          '实名',
          '性别',
        ], [
          personalData.realName!,
          PersonalData.sexToString(personalData.sex!),
        ]),
        _buildDetailLine([
          '母语',
          '生日',
        ], [
          personalData.nativeLanguage!,
          PersonalData.birthToString(personalData.birth!),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _hasToken()
        ? _buildLoggedinPage(context)
        : _buildUnloggedinPage(context);
  }

  Widget _buildUnloggedinPage(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 40.0),
          child: Container(
            height: 64.0,
            alignment: Alignment.topCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.person,
                  size: 32.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!AuthritionState.get().hasToken()) {
                      Navigator.pushNamed(context, LoginScreen.routeName);
                    }
                  },
                  style: gPersonalPageLoginButtonStyle,
                  child: Text(
                    '尚未登录, 点击登录',
                    style: gPersonalPageNicknameStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(
              Icons.lock,
              size: 240.0,
              color: Colors.grey,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '登录解锁更多内容',
              style: gSubtitleStyle,
            )
          ],
        ),
      ],
    );
  }

  Widget _buildLoggedinPage(BuildContext context) {
    return FutureBuilder<PersonalData?>(
      future: fetchPersonalData(AuthritionState.get().getToken()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return Scaffold(
            body: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                _buildDetailsPanel(snapshot.data!),
                const Subtitle(label: '推荐内容'),
                _buildRecWidget(personalRecDatasFirst),
                _buildRecWidget(personalRecDatasSecond),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
