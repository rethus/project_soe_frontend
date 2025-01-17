import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart' as mime;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;

import 'package:project_soe/CComponents/ComponentVoiceInput.dart';
import 'package:project_soe/CComponents/LogicPingyinlizer.dart' as pinyinlizer;
import 'package:project_soe/GGlobalParams/Styles.dart';
import 'package:project_soe/VExam/MsgQuestion.dart';
import 'package:project_soe/VExam/ViewExamResults.dart';
import 'package:project_soe/LNavigation/LogicNavigation.dart';

class ArgsViewExamResult {
  final String id;
  final String endingRoute;
  final List<DataQuestionPageMain> dataList;
  ArgsViewExamResult(this.id, this.dataList, this.endingRoute);
}

class ArgsViewExam {
  final String cprsgrpId;
  final String title;
  final String endingRoute;
  ArgsViewExam(this.cprsgrpId, this.title, this.endingRoute) {
    if (sNavigationRoutes[endingRoute] == null) {
      throw ('ROUTE NAME NOT FOUND');
    }
  }
}

enum QuestionType {
  word,
  sentance,
  article,
  poem,
}

// 转换为拼音 pin1 yin1 -> pīn yīn
String getStringFromPinyin(String pinyin) {
  return pinyinlizer.Pinyinizer().pinyinize(pinyin);
}

// 获取调型对应的文本
String getLabelFromMonotoneInt(int monoTone) {
  switch (monoTone) {
    case 1:
      return '一声';
    case 2:
      return '二声';
    case 3:
      return '三声';
    case 4:
      return '四声';
    default:
      throw ('没有该调型');
  }
}

// 获取讯飞数据的解析格式
String getXfCategoryStringByInt(int x) {
  switch (x) {
    case 2:
      return 'read_word';
    case 3:
      return 'read_sentence';
    case 4:
      return 'read_chapter';
    default:
      throw ('不支持的格式');
  }
}

// 错误声韵母列表整理为一个String
String getStringLabelFromWrongPhoneList(List<WrongPhone> phoneList) {
  String ret = '';
  for (WrongPhone phone in phoneList) {
    ret += phone.word;
    ret += phone.pinyinString;
  }
  return ret;
}

// 错误调型列表整理为一个String
String getStringLabelFromWrongMonoList(List<WrongMonoTone> monoList) {
  String ret = '';
  for (WrongMonoTone monoTone in monoList) {
    ret += monoTone.word;
    ret += monoTone.pinyinString;
  }
  return ret;
}

// 获取调型Int 1234
int getMonoToneIntFromPinyin(String pinyin) {
  if (pinyin == null) {
    return 0;
  }
  int rightMonotone = 0;
  int pinyinLength = pinyin.length;
  rightMonotone = int.parse(pinyin[pinyinLength - 1]);
  return rightMonotone;
}

// 获取调型String
int getMonoToneIntFromMsgString(String monoTone) {
  switch (monoTone) {
    case 'TONE1':
      return 1;
    case 'TONE2':
      return 2;
    case 'TONE3':
      return 3;
    case 'TONE4':
      return 4;
    default:
      throw ('没有该调型');
  }
}

// 评测之后返回的数据经解析的结果
class ParsedResultsXf {
  String cpsgrpId;
  // TODO 23.4.22 dart有tuple可以使用, 但此处不研究这么开启. 只使用两个list
  List<ItemResult> itemList;
  List<DataResultXf> resultList;
  double weightedScore;
  double totalWeight;
  Map<String, List<WrongPhone>> wrongShengs;
  Map<String, List<WrongPhone>> wrongYuns;
  Map<String, List<WrongMonoTone>> wrongMonos;

  ParsedResultsXf({
    required this.cpsgrpId,
    required this.itemList,
    required this.resultList,
    required this.weightedScore,
    required this.totalWeight,
    required this.wrongShengs,
    required this.wrongYuns,
    required this.wrongMonos,
  });

  String toJson() {
    String ret = '';
    ret += '{';
    ret += '"wrongSheng":{';
    for (final wrongSheng in wrongShengs.keys) {
      ret += wrongSheng + ':[';
      final lst = wrongShengs[wrongSheng];
      if (lst != null) {
        for (final ws in lst) {
          ret += '${ws.toJson()},';
        }
      }
      ret += '],';
    }
    ret += '},';
    ret += '"wrongYun":{';

    for (final wys in wrongYuns.keys) {
      ret += wys + ':[';
      final lst = wrongShengs[wys];
      if (lst != null) {
        for (final wy in lst) {
          ret += '${wy.toJson()},';
        }
      }
      ret += '],';
    }
    ret += '},';
    ret += '"wrongMono":{';

    for (final wms in wrongMonos.keys) {
      ret += wms + ':[';
      final lst = wrongShengs[wms];
      if (lst != null) {
        for (final wm in lst) {
          ret += '${wm.toJson()},';
        }
      }
      ret += '],';
    }
    ret += '},';
    ret += '}';
    return ret;
  }

  factory ParsedResultsXf.fromQuestionPageDataList(
      List<DataQuestionPageMain> dataList, String cpsgrpId) {
    List<DataResultXf> list = List.empty(growable: true);

    List<ItemResult> itemList = List.empty(growable: true);
    double weightedScore = 0.0;
    double totalWeight = 0.0;
    for (var pageData in dataList) {
      double pageWeight = pageData.weight;
      totalWeight += pageWeight;
      if (pageData.resultXf != null) {
        list.add(pageData.resultXf!);
        double gotScore = pageData.resultXf!.totalScore * pageWeight;
        weightedScore += gotScore;
        itemList.add(ItemResult(
            gotScore: gotScore,
            fullScore: pageWeight,
            tNum: pageData.tnum,
            cNum: pageData.cnum));
      } else {
        itemList.add(ItemResult(
            gotScore: 0.0,
            fullScore: pageWeight,
            tNum: pageData.tnum,
            cNum: pageData.cnum));
      }
    }
    for (ItemResult item in itemList) {
      item.gotScore /= totalWeight;
    }
    Map<String, List<WrongPhone>> wrongShengs = Map.identity();
    Map<String, List<WrongPhone>> wrongYuns = Map.identity();
    Map<String, List<WrongMonoTone>> wrongMonos = Map.identity();
    for (var resultXf in list) {
      if (resultXf.wrongSheng.isNotEmpty) {
        for (var sheng in resultXf.wrongSheng) {
          if (!wrongShengs.containsKey(sheng.shengmu)) {
            wrongShengs[sheng.shengmu] = List.empty(growable: true);
          }
          wrongShengs[sheng.shengmu]!.add(sheng);
        }
      }
      if (resultXf.wrongYun.isNotEmpty) {
        for (var yun in resultXf.wrongYun) {
          if (!wrongYuns.containsKey(yun.yunmu)) {
            wrongYuns[yun.yunmu] = List.empty(growable: true);
          }
          wrongYuns[yun.yunmu]!.add(yun);
        }
      }
      if (resultXf.wrongMonotones.isNotEmpty) {
        for (var mono in resultXf.wrongMonotones) {
          String toneLabel = getLabelFromMonotoneInt(mono.tone);
          if (!wrongMonos.containsKey(toneLabel)) {
            wrongMonos[toneLabel] = List.empty(growable: true);
          }
          wrongMonos[toneLabel]!.add(mono);
        }
      }
    }
    return ParsedResultsXf(
      itemList: itemList,
      weightedScore: (weightedScore / totalWeight),
      totalWeight: totalWeight,
      resultList: list,
      cpsgrpId: cpsgrpId,
      wrongShengs: wrongShengs,
      wrongYuns: wrongYuns,
      wrongMonos: wrongMonos,
    );
  }
}

// 基类, 记录录音情况和评测内容
// DataQuestrionPageXXX extends DataQuestionEval {
//    + other data
// }
class DataQuestionEval {
  // 应该是由上层存储的, 但是传递下来
  final int evalMode;
  bool _isRecording = false;
  bool _isUploading = false;
  String _filePath = '';
  // 评测以页为单位, 因此页数据内包含结果
  DataResultXf? resultXf;

  DataQuestionEval({
    required this.evalMode,
  });

  // 虚函数, 用来获取发送给服务器用来评测的内容
  String toSingleString() {
    return '';
  }

  // 虚函数, 用来获取评测时的满分
  double getWeight() {
    return 100.0;
  }

  TextSpan _wrongWord(String txt, int size) {
    return TextSpan(text: txt, style: TextStyle());
  }

  TextSpan _normalWord(String txt, int size) {
    return TextSpan(text: txt, style: TextStyle());
  }

  // 获取字体的size
  double getAdaptiveSize(int strLen) {
    if (strLen < 50) {
      return 22;
    }
    if (strLen < 120) {
      return 18;
    }
    return 14;
  }

  Widget getRichText4Show(bool showWrongs) {
    final str = toSingleString();
    final adaSize = getAdaptiveSize(str.length);
    if (!showWrongs) {
      return Text(
        str,
        style: TextStyle(
          fontFamily: 'SourceSans',
          color: Color.fromARGB(255, 1, 41, 50),
          fontSize: adaSize,
        ),
      );
    }
    List<TextSpan> childrenSpanList = resultXf!.spanList
        .map(
          (spanInfo) => TextSpan(
            text: spanInfo.label,
            style: TextStyle(
              fontFamily: 'SourceSans',
              color: spanInfo.isWrong ? Color(0xefff1e1e) : Color(0xff2a2a2a),
              fontSize: adaSize,
            ),
          ),
        )
        .toList();
    return RichText(
      text: TextSpan(children: childrenSpanList),
    );
  }

  // 发送结果至服务器评测
  Future<void> postAndGetResultXf() async {
    if (_filePath == '') {
      return;
    }
    _isUploading = true;
    resultXf = await MsgMgrQuestion().postAndGetResultXf(this);
    // 标定状态
    _isUploading = false;
  }

  // 将语音文件转换为可以被发送的 MultiPartFileAudio
  Future<http.MultipartFile> getMultiPartFileAudio() async {
    dynamic httpAudio;
    if (_filePath != '') {
      final bytes = await File(_filePath).readAsBytes();
      final fileSplit = _filePath.split('\\');
      final String fileName = fileSplit[fileSplit.length - 1];
      final String mimeLook = mime.lookupMimeType(_filePath)!;
      final mimeSplit = mimeLook.split('/');
      final String mimeString = mimeSplit[0];
      final String mimeType = mimeSplit[1];
      httpAudio = http.MultipartFile.fromBytes(
        'audio',
        bytes,
        filename: fileName,
        contentType: http_parser.MediaType(
          mimeString,
          mimeType,
        ),
      );
    }
    return httpAudio;
  }

  // getters&setters
  bool hasRecordFile() {
    return _filePath != '';
  }

  void setFilePath(String filePath) {
    _filePath = filePath;
  }

  String getFilePath() {
    return _filePath;
  }

  bool isRecording() {
    return _isRecording;
  }

  void setRecording(bool bRecording) {
    _isRecording = bRecording;
  }

  bool isUploading() {
    return _isUploading;
  }

  void setUploading(bool bUploading) {
    _isUploading = bUploading;
  }
}

// 跟读页的每页题目数据
// class DataQuestionPageFollow {
//   String followFilePath;
//   final String title;
//   final String desc;
//   DataQuestionEval dataEval;
//   final List<DataQuestion> questionList;
//   DataQuestionPageFollow({
//     required this.questionList,
//     required this.dataEval,
//     this.desc = '',
//     this.title = '',
//     this.followFilePath = '',
//   });
// }

// 每一页题目的数据.
class DataQuestionPageMain extends DataQuestionEval {
  // final QuestionType type;
  final String id;
  final int cnum;
  final int tnum;
  final String cpsgrpId;
  final double weight;
  final String title;
  final String desc;
  DataQuestion dataQuestion;

  // 可以播放的录音, 为空的时候代表没有示例
  final String audioUri;
  bool _isPlayingExample = false;
  bool _isStartPlaying = false;
  // 播放进度
  double playingProgress = 0.0;

  bool isStartPlaying() {
    return _isStartPlaying;
  }

  void setStartPlaying(bool bStart) {
    _isStartPlaying = bStart;
  }

  bool isPlayingExample() {
    return _isPlayingExample;
  }

  void setPlayingExample(bool bPlayingExample) {
    _isPlayingExample = bPlayingExample;
  }

  DataQuestionPageMain({
    required super.evalMode,
    required this.id,
    required this.dataQuestion,
    required this.cnum,
    required this.tnum,
    required this.cpsgrpId,
    required this.weight,
    required this.title,
    required this.desc,
    required this.audioUri,
  });

  // 用来发送评测的内容
  @override
  String toSingleString() {
    String ret = '';
    List<String> lines = dataQuestion.label.split('\\n');
    for (String line in lines) {
      ret += (super.evalMode == 4 ? '     ' : '') + line;
      ret += '\n';
    }
    return ret;
  }

  // 获取得分信息
  String getScoreDescString() {
    return '第${this.tnum}大题第${this.cnum}小题' +
        '(本题满分:${weight.toStringAsFixed(1)})' +
        '\n';
  }
}

// 每一道题的数据
class DataQuestion {
  final String id;
  final String label;
  final int evalMode;
  final String cpsgrpId;
  final String topicId;
  final double wordWeight;
  const DataQuestion({
    required this.wordWeight,
    required this.id,
    required this.label,
    required this.cpsgrpId,
    required this.topicId,
    required this.evalMode,
  });
  factory DataQuestion.fromJson(Map<String, dynamic> json) {
    return DataQuestion(
      wordWeight:
          json['wordWeight'] != null ? json['wordWeight'] as double : 0.0,
      id: json['id'] as String,
      label: json['refText'] as String,
      cpsgrpId: json['cpsgrpId'] as String,
      topicId: json['topicId'] as String,
      evalMode: json['evalMode'] as int,
    );
  }
  Map<String, dynamic> toDynamicMap() {
    Map<String, dynamic> json = {};
    json['word'] = label;
    json['pinyin'] = '';
    return json;
  }
}

class DataSpanInfo {
  String label;
  bool isWrong;
  String symbol;
  DataSpanInfo({
    required this.label,
    required this.isWrong,
    required this.symbol,
  });
}

// 科大讯飞评测得到的结果
// phone_score 	声韵分
// fluency_score 	流畅度分（暂会返回0分）
// tone_score 	调型分
// total_score 	总分
// beg_pos/end_pos 	始末位置（单位：帧，每帧相当于10ms)
// content 	试卷内容
// time_len 	时长（单位：帧，每帧相当于10ms）
class DataResultXf {
  double weight;
  double weightedScore;
  bool jsonParsed;
  int evalMode;
  double fluencyScore;
  double phoneScore;
  double toneScore;
  double totalScore;
  int more; // 增读
  int less; // 漏读
  int retro; // 回读
  int repl; // 替换
  late List<WrongMonoTone> wrongMonotones;
  late List<WrongPhone> wrongSheng;
  late List<WrongPhone> wrongYun;
  late List<DataSpanInfo> spanList;
  DataResultXf({
    required this.evalMode,
    required this.weight,
    this.jsonParsed = false,
    this.fluencyScore = 0.0,
    this.phoneScore = 0.0,
    this.toneScore = 0.0,
    this.totalScore = 0.0,
    this.more = 0,
    this.less = 0,
    this.retro = 0,
    this.repl = 0,
    this.weightedScore = 0.0,
  }) {
    weightedScore = weight * totalScore;
    wrongMonotones = List.empty(growable: true);
    wrongSheng = List.empty(growable: true);
    wrongYun = List.empty(growable: true);
    spanList = List.empty(growable: true);
  }

  bool _parsePhone(Map<String, dynamic> phone, Map<String, dynamic> syrllJson) {
    if (phone['perr_msg'] != 0) {
      if (phone['is_yun'] == 1) {
        if (phone['perr_msg'] == 1) {
          wrongYun.add(
            WrongPhone(
              word: syrllJson['content'],
              yunmu: phone['content'],
              shengmu: '',
              isShengWrong: false,
              pinyinString: getStringFromPinyin(syrllJson['symbol']),
            ),
          );
        } else if (phone['perr_msg'] == 2) {
          wrongMonotones.add(
            WrongMonoTone(
              word: syrllJson['content'],
              tone: getMonoToneIntFromMsgString(phone['mono_tone']),
              pinyinString: getStringFromPinyin(syrllJson['symbol']),
            ),
          );
        } else if (phone['perr_msg'] == 3) {
          wrongYun.add(
            WrongPhone(
                word: syrllJson['content'],
                yunmu: phone['content'],
                shengmu: '',
                isShengWrong: false,
                pinyinString: getStringFromPinyin(syrllJson['symbol'])),
          );
          wrongMonotones.add(
            WrongMonoTone(
              word: syrllJson['content'],
              tone: getMonoToneIntFromMsgString(phone['mono_tone']),
              pinyinString: getStringFromPinyin(syrllJson['symbol']),
            ),
          );
        } else {
          throw ('未知的错误信息');
        }
      } else if (phone['is_yun'] == 0) {
        if (phone['perr_msg'] == 1) {
          wrongSheng.add(
            WrongPhone(
              word: syrllJson['content'],
              yunmu: '',
              shengmu: phone['content'],
              isShengWrong: true,
              pinyinString: getStringFromPinyin(syrllJson['symbol']),
            ),
          );
        } else {
          throw ('未知的错误信息');
        }
      } else {
        throw ('错误的声韵母信息');
      }
      return true;
    }
    return false;
  }

  void _parseSyrll(Map<String, dynamic> syrllJson) {
    if (syrllJson['content'] == 'silv' ||
        syrllJson['content'] == 'sil' ||
        syrllJson['content'] == 'fil') {
      return;
    }
    bool wrongSyrll = false;
    try {
      if (syrllJson['dp_message'] == 0) {
        // int rightMonotone =
        //     getMonoToneIntFromPinyin(syrllJson['symbol'].toString());
        final phoneJson = syrllJson['phone'];
        if (_isJsonList(phoneJson)) {
          for (var phone in phoneJson) {
            wrongSyrll = wrongSyrll || _parsePhone(phone, syrllJson);
          }
        } else {
          wrongSyrll = wrongSyrll || _parsePhone(phoneJson, syrllJson);
        }
      } else {
        switch (syrllJson['dp_message']) {
          case 16:
            less++;
            break;
          case 32:
            more++;
            break;
          case 64:
            retro++;
            break;
          case 128:
            repl++;
            break;
          default:
            break;
        }
      }
    } catch (_) {}
    spanList.add(
      DataSpanInfo(
        label: syrllJson['content'],
        isWrong: wrongSyrll,
        symbol: syrllJson['symbol'],
      ),
    );
  }

  void _parseWord(Map<String, dynamic> wordJson) {
    if (_isJsonList(wordJson['syll'])) {
      for (var syrllJson in wordJson['syll']) {
        _parseSyrll(syrllJson);
      }
    } else {
      _parseSyrll(wordJson['syll']);
    }
  }

  bool _isJsonList(var json) {
    final ret = json[1];
    if (ret != null) {
      return true;
    } else {
      return false;
    }
  }

  // 将解析后的单字spanlist合并
  void _mergeSpanList() {
    if (spanList.isEmpty) {
      return;
    }
    List<DataSpanInfo> mergedList = List.empty(growable: true);
    bool wrong = spanList[0].isWrong;
    String tempStr = spanList[0].label;
    String tempSymb = spanList[0].symbol;
    for (int i = 1; i < spanList.length; ++i) {
      final curSpan = spanList[i];
      if (curSpan.isWrong != wrong) {
        // save
        mergedList.add(DataSpanInfo(
          label: tempStr,
          isWrong: wrong,
          symbol: tempSymb,
        ));
        wrong = curSpan.isWrong;
        tempStr = curSpan.label;
        tempSymb = curSpan.symbol;
      } else {
        // merge
        tempStr += curSpan.label;
        tempSymb += curSpan.symbol;
      }
    }
    // save
    mergedList.add(DataSpanInfo(
      label: tempStr,
      isWrong: wrong,
      symbol: tempSymb,
    ));
    spanList = mergedList;
  }

  void parseJson(Map<String, dynamic> json) {
    String category = getXfCategoryStringByInt(evalMode);
    Map<String, dynamic> resultJson = json['rec_paper'][category];
    fluencyScore = resultJson['fluency_score'];
    phoneScore = resultJson['phone_score'];
    totalScore = resultJson['total_score'];
    toneScore = resultJson['tone_score'];

    // hacks:使用try处理json不能被迭代的情况.
    try {
      for (var sentanceJson in resultJson['sentence']) {
        if (_isJsonList(sentanceJson['word'])) {
          for (var wordJson in sentanceJson['word']) {
            _parseWord(wordJson);
          }
        } else {
          _parseWord(sentanceJson['word']);
        }
      }
    } catch (_) {
      var sentanceJson = resultJson['sentence'];
      if (_isJsonList(sentanceJson['word'])) {
        for (var wordJson in sentanceJson['word']) {
          _parseWord(wordJson);
        }
      } else {
        _parseWord(sentanceJson['word']);
      }
    }
    _mergeSpanList();

    jsonParsed = true;
  }
}

// 错误的声韵母
class WrongPhone {
  final String word;
  final String shengmu;
  final String yunmu;
  final bool isShengWrong;
  final String pinyinString;
  const WrongPhone({
    required this.word,
    required this.shengmu,
    required this.yunmu,
    required this.isShengWrong,
    required this.pinyinString,
  });

  String toJson() {
    final map = {
      'word': word,
      'shengmu': shengmu,
      'yunmu': yunmu,
      'isShengWrong': isShengWrong,
      'pinyinString': pinyinString,
    };
    return jsonEncode(map);
  }
}

// 错误的调型
class WrongMonoTone {
  final String word;
  final int tone;
  final String pinyinString;
  const WrongMonoTone({
    required this.word,
    required this.tone,
    required this.pinyinString,
  });

  String toJson() {
    final map = {
      'word': word,
      'tone': tone,
      'pinyin': pinyinString,
    };
    return jsonEncode(map);
  }
}

// 小题情况
class ItemResult {
  double gotScore;
  final double fullScore;
  final int tNum;
  final int cNum;
  ItemResult({
    required this.gotScore,
    required this.fullScore,
    required this.tNum,
    required this.cNum,
  });

  String toJson() {
    final map = {
      'gotScore': gotScore,
      'fullScore': fullScore,
      'tNum': tNum,
      'cNum': cNum,
    };
    return jsonEncode(map);
  }
}
