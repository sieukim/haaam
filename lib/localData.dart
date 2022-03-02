import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alarm.dart';

class LocalData {
  // 로컬 저장소 객체
  late SharedPreferences prefs;

  // 로컬 저장소에 저장된 알람 목록 (String)
  late List<String> alarmList = [];

  // 로컬 저장소에 저장된 알람 제목 목록 (String)
  late List<String> titleList = [];

  // 상태로 저장된 알람 목록 (Alarm)
  late List<Alarm> alarmListState = [];

  init() async {
    prefs = await SharedPreferences.getInstance();
    alarmList = prefs.getStringList('alarmList') ?? [];
    titleList = prefs.getStringList('titleList') ?? [];

    for (var i = 0; i < alarmList.length; i++) {
      // json 객체로 변환
      var decoded = jsonDecode(alarmList[i]);
      String _title = decoded['title'];
      String _timeList = decoded['timeList'];
      bool _activated = decoded['activated'] == 'true' ? true : false;

      Alarm _alarm = Alarm(_title, _timeList, _activated);
      alarmListState.add(_alarm);
    }
  }

  // 알람 저장
  save({
    required Alarm alarm,
    required BuildContext context,
  }) {
    // 알람 객체 갱신
    alarmList.add(alarm.toString());
    alarmListState.add(alarm);
    titleList.add(alarm.title.toString());
    // 로컬 저장소 갱신
    prefs.setStringList('alarmList', alarmList);
    prefs.setStringList('titleList', titleList);
  }

  // 알람 편집
  edit({
    // 기존 알람 객체
    required Alarm previousAlarm,
    // 변경된 알람 객체
    required Alarm nextAlarm,
    required BuildContext context,
  }) {
    // 기존 알람 객체 위치
    int index = alarmList.indexOf(previousAlarm.toString());
    // 알람 객체 갱신
    alarmList[index] = nextAlarm.toString();
    alarmListState[index] = nextAlarm;
    titleList[index] = nextAlarm.title.toString();
    // 로컬 저장소 갱신
    prefs.setStringList('alarmList', alarmList);
    prefs.setStringList('titleList', titleList);
  }

  // 알람 삭제
  remove({required Alarm alarm}) {
    // 알람 객체 삭제
    alarmList.remove(alarm.toString());
    alarmListState.remove(alarm);
    titleList.remove(alarm.title.toString());
    // 로컬 저장소 갱신
    prefs.setStringList('alarmList', alarmList);
    prefs.setStringList('titleList', titleList);
  }

  // 활성화 상태 onChanged 핸들러
  onChangedActivated({required bool activated, required int index}) {
    // 기존 알람 객체
    Alarm alarm = alarmListState[index];
    // 활성화 상태 변경
    alarm.activated = activated;
    // 알람 객체 갱신
    alarmList[index] = alarm.toString();
    alarmListState[index] = alarm;
    // 로컬 저장소 갱신
    prefs.setStringList('alarmList', alarmList);
  }
}
