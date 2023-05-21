import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:project_soe/src/VAuthorition/DataAuthorition.dart';
import 'package:project_soe/src/VAuthorition/LogicAuthorition.dart';

String _convertErrCodetoString(int err) {
  switch (err) {
    case 250001:
      return '账号已经存在';
    case 250002:
      return '账号不存在';
    case 250003:
      return '账号或者密码错误';
    case 250004:
      return '账号未登录';
    case 250005:
      return '未授权的操作';
    case 250006:
      return '用户登录信息异常或已失效';
    case 250007:
      return '仅支持中国大陆手机号，改手机号格式有误';
    case 250008:
      return '您输入的数据格式错误或您没有权限访问资源';
    default:
      throw ('未知的错误码');
  }
}

// 这里用的LoginData & SignupData不是soe项目定义的, 而是package:flutter_login里定义的
class MsgAuthorition {
  Future<String?> postUserAuthorition(DataCredentials data) async {
    final client = http.Client();
    final bodyMap = {
      'phone': data.userName,
      'pwd': data.password,
    };
    final response = await client.post(
      Uri.parse('http://47.101.58.72:8888/user-server/api/user/v1/login'),
      body: jsonEncode(bodyMap),
      headers: {"Content-Type": "application/json"},
      encoding: Encoding.getByName('utf-8'),
    );
    final u8decoded = utf8.decode(response.bodyBytes);
    final decoded = jsonDecode(u8decoded);
    if (decoded['code'] == 0) {
      AuthritionState.instance.setlogIn(data, decoded['data']);
      return null;
    } else {
      return _convertErrCodetoString(decoded['code']);
    }
  }

  Future<String?> postSignupUser(DataSignup data) async {
    final client = http.Client();
    final bodyMap = {
      'phone': data.userName,
      'pwd': data.password,
      'nickName': data.nickName,
    };
    final response = await client.post(
      Uri.parse('http://47.101.58.72:8888/user-server/api/user/v1/register'),
      body: jsonEncode(bodyMap),
      headers: {"Content-Type": "application/json"},
      encoding: Encoding.getByName('utf-8'),
    );
    final u8decoded = utf8.decode(response.bodyBytes);
    final decoded = jsonDecode(u8decoded);
    if (decoded['code'] == 0) {
      return null;
    } else {
      return _convertErrCodetoString(decoded['code']);
    }
  }

  Future<DataUserInfo?> getDataUserInfo(String token) async {
    // FIXME 23.4.13
    // token =
    //     'soe-token-eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJzbWFydC1vcmFsLWV2YWx1YXRpb24iLCJsb2dpblVzZXIiOnsiYWNjb3VudE5vIjoidXNlcl8xNTg3NDIyOTk5MDQzMjQ4MTI4IiwiaWRlbnRpZnlJZCI6IjY2NiIsInJvbGVJZCI6Mywibmlja05hbWUiOiIxODc4Njk3ODI3MiIsInJlYWxOYW1lIjoidGd4IiwiZmlyc3RMYW5ndWFnZSI6MiwicGhvbmUiOiIxODc4Njk3ODI3MiIsIm1haWwiOiIxNDMzMzgxNTM0QHFxLmNvbSJ9LCJpYXQiOjE2ODEyNzk0NDMsImV4cCI6MTY4MTg4NDI0M30.KuKIB_6s9wa5c7gLvAR8tl2I1k1zwlKiZe6o42AGBg4';
    final client = http.Client();
    final response = await client.get(
      Uri.parse('http://47.101.58.72:8888/user-server/api/user/v1/info'),
      headers: {
        'token': token,
      },
    );
    final u8decoded = utf8.decode(response.bodyBytes);
    final decoded = jsonDecode(u8decoded);
    final accountId = decoded['data']['accountNo'];
    var userInfo = DataUserInfo(token, accountId);
    userInfo.parseJson(decoded['data']);
    return userInfo;
  }
}
