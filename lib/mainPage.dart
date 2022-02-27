import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haaam/editPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  final String? alarms;

  const MainPage({Key? key, this.alarms}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 상태로 저장된 알람 목록
  final _alarmListState = <Map<String, dynamic>>[];

  // 로컬 저장소에 저장된 알람 목록
  List<String> _alarmListLocal = [];

  // 로컬 저장소에 저장된 알람 제목 목록
  late List<String> _alarmTitleLocal;

  bool _editable = false;

  // 로컬 저장소에 저장된 알람 목록 가져오기
  _loadAlarmList() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _alarmListLocal = _prefs.getStringList('alarmList') ?? [];
    _alarmTitleLocal = _prefs.getStringList('alarmTitleList') ?? [];

    setState(() {
      for (var i = 0; i < _alarmListLocal.length; i++) {
        var _alarm = jsonDecode(_alarmListLocal[i]);
        _alarmListState.add(_alarm);
      }
    });
  }

  // CupertinoSwitch onChanged 핸들러
  _onChangedSwitch(value, index) async {
    setState(() {
      _alarmListState[index]['activated'] = "$value";

      var _alarmTitle = _alarmListState[index]['title'];
      var _timeList = _alarmListState[index]['timeList'];
      var _activated = value;

      _alarmListLocal[index] =
          '{"title": "$_alarmTitle", "timeList": "$_timeList", "activated": "$_activated"}';
    });

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setStringList('alarmList', _alarmListLocal);
  }

  // 알람 삭제 버튼 onPressed 핸들러
  _onPressedDelete(index) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    setState(() {
      // 상태로 저장된 알람 목록
      _alarmListState.remove(_alarmListState[index]);

      // 로컬 저장소에 저장된 알람 목록
      _alarmListLocal.remove(_alarmListLocal[index]);

      // 로컬 저장소에 저장된 제목 목록
      _alarmTitleLocal.remove(_alarmTitleLocal[index]);
    });

    _prefs.setStringList('alarmList', _alarmListLocal);
    _prefs.setStringList('alarmTitleList', _alarmTitleLocal);
  }

  @override
  void initState() {
    super.initState();
    _loadAlarmList();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 size
    final _size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: _editable ? const Text('완료') : const Text('편집'),
          onPressed: () {
            setState(() {
              _editable = !_editable;
            });
          },
        ),
        middle: const Text('알람'),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () async {
            final _alarm = await Navigator.of(context).pushNamed('/add');
            setState(() {
              if (_alarm != null) {
                _alarmListState.add(jsonDecode(_alarm.toString()));
                _alarmListLocal.add(_alarm.toString());
              }
            });
          },
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Map<String, dynamic> _alarm = _alarmListState[index];
                String _title = _alarm['title'];
                bool _activated = _alarm['activated'] == 'true';
                return _alarmListState.isNotEmpty
                    ? GestureDetector(
                        child: Container(
                          height: _size.height * 0.1,
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_title),
                              _editable
                                  ? CupertinoButton(
                                      padding: const EdgeInsets.all(0),
                                      child: Stack(
                                        children: const [
                                          Icon(
                                            CupertinoIcons.minus,
                                            color: CupertinoColors.white,
                                            size: 30,
                                          ),
                                          Icon(
                                            CupertinoIcons.minus_circle_fill,
                                            color: CupertinoColors.systemRed,
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        _onPressedDelete(index);
                                      },
                                    )
                                  : CupertinoSwitch(
                                      value: _activated,
                                      onChanged: (value) {
                                        _onChangedSwitch(value, index);
                                      },
                                    ),
                            ],
                          ),
                        ),
                        onTap: () async {
                          final _result = await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => EditPage(alarm: _alarm),
                            ),
                          );
                          setState(() {
                            if (_result['type'] == 'delete' &&
                                _result['alarm'] != null) {
                              _alarmListState.remove(_result['alarm']);
                            }

                            if (_result['type'] == 'edit' &&
                                _result['alarm'] != null) {
                              _alarmListState.remove(_alarm);
                              _alarmListState.add(jsonDecode(_result['alarm']));
                            }
                          });
                        },
                      )
                    : const Text('알람을 추가해주세요');
              },
              itemCount: _alarmListState.length,
              padding: const EdgeInsets.all(20),
              separatorBuilder: (context, index) => const Divider(
                color: CupertinoColors.systemFill,
                thickness: 2,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
