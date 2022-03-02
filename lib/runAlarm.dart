import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:haaam/globalVariable.dart';
import 'package:intl/intl.dart';

import 'localData.dart';

class RunAlarm extends StatefulWidget {
  const RunAlarm({Key? key}) : super(key: key);

  @override
  _RunAlarmState createState() => _RunAlarmState();
}

class _RunAlarmState extends State<RunAlarm> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Center(
      child: CupertinoButton.filled(
        child: const Text('종료'),
        onPressed: () {
          Navigator.of(context).pop();
          FlutterRingtonePlayer.stop();
        },
      ),
    ));
  }
}

// '오전/오후 시간(1~12):분' 형식의 시간 문자열을 '시간(1~24):분' 형식으로 변환하는 함수
_convert(String str) {
  var token = str.split(' ').map((element) => element.split(':')).toList();
  var ampm = token[0][0].toString();
  var hour = int.parse(token[1][0]);
  var minute = int.parse(token[1][1]);

  if (ampm == '오전') {
    return '$hour:$minute';
  } else {
    return '${hour + 12}:$minute';
  }
}

// 알람 타이머
runAlarm() {
  late BuildContext? context;

  // 현재 Context 가져오기
  SchedulerBinding.instance?.addPostFrameCallback((_) {
    context = GlobalVariable.navigatorState.currentContext;
  });

  return Timer.periodic(const Duration(minutes: 1), (timer) async {
    // 로컬 데이터 가져오기
    LocalData _localData = LocalData();
    await _localData.init();
    // 활성화된 알람 시간 리스트
    List<String> _activatedTimeList = [];
    // 로컬 데이터에서 활성화된 알람 리스트만 찾아 추가
    _localData.alarmListState.forEach((alarm) {
      if (alarm.activated) {
        List<String> _timeList = alarm.timeList.split(',');
        _timeList.forEach((time) {
          _activatedTimeList.add(_convert(time));
        });
      }
    });
    // 현재 시각
    final _currentTime = DateFormat('k:mm').format(DateTime.now()).toString();
    // 알람 시간인 경우
    if (_activatedTimeList.contains(_currentTime)) {
      FlutterRingtonePlayer.playAlarm(volume: 10, looping: true);
      Navigator.of(context!).pushNamed('/alarm');
    }
  });
}
