import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haaam/editPage.dart';
import 'package:haaam/localData.dart';

import 'addPage.dart';
import 'alarm.dart';

class MainPage extends StatefulWidget {
  final String? alarms;

  const MainPage({Key? key, this.alarms}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 로컬 저장소 객체
  late LocalData _localData;

  // 편집 상태 여부
  bool _editable = false;

  // 네비게이션 바 내 leading 버튼 객체를 반환하는 함수
  _getLeadingButton() {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      child: _editable ? const Text('완료') : const Text('편집'),
      onPressed: () {
        setState(() {
          _editable = !_editable;
        });
      },
    );
  }

  // 네비게이션 바 내 leading 버튼 객체를 반환하는 함수
  _getTrailingButton() {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: () async {
        // 네비게이션 & 추가 페이지에서 반환하는 알람 객체 받아오기
        final _result = await Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => const AddPage(),
          ),
        );

        setState(() {
          // 알람 저장인 경우
          if (_result['type'] == 'save') {
            // 상태에 알람 객체 추가
            _localData.alarmListState.add(_result['alarm']);
          }
        });
      },
      child: const Icon(CupertinoIcons.add),
    );
  }

  // 알람 객체 삭제 버튼 객체를 반환하는 함수
  _getRemoveButton({required Alarm alarm}) {
    return CupertinoButton(
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
        setState(() {
          _localData.remove(alarm: alarm);
        });
      },
    );
  }

  // 알람 객체 활성화 switch 객체를 반환하는 함수
  _getActivatedSwitch({required bool activated, required int index}) {
    return CupertinoSwitch(
      value: activated,
      onChanged: (value) {
        setState(() {
          _localData.onChangedActivated(
            activated: value,
            index: index,
          );
        });
      },
    );
  }

  // 알람 리스트 뷰 내 아이템 onTap 핸들러
  _onTapItem({required Alarm alarm}) async {
    // 탭한 알람 객체와 함께 네비게이션 & 편집 페이지에서 반환하는 알람 객체 받아오기
    final _result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => EditPage(alarm: alarm),
      ),
    );

    setState(() {
      // 알람 수정인 경우
      if (_result['type'] == 'edit') {
        // 상태에서 기존 알람 객체 위치
        int index = _localData.alarmListState.indexOf(alarm);
        // 상태에 변경 알람 객체 갱신
        _localData.alarmListState[index] = _result['alarm'];
      }
      // 알람 삭제인 경우
      if (_result['type'] == 'remove') {
        // 상태에서 해당 알람 객체 삭제
        _localData.alarmListState.remove(_result['alarm']);
      }
    });
  }

  // 알람 리스트 뷰
  _getListView(Size _size) {
    return ListView.separated(
      itemBuilder: (context, index) {
        Alarm _alarm = _localData.alarmListState[index];
        return _localData.alarmListState.isNotEmpty
            ? SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: SizedBox(
                        child: Text(
                          _alarm.title.toString(),
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: _alarm.activated
                                ? CupertinoColors.white
                                : CupertinoColors.inactiveGray,
                          ),
                        ),
                        width: _size.width * 0.7,
                      ),
                      onTap: () => _onTapItem(alarm: _alarm),
                    ),
                    _editable
                        ? _getRemoveButton(alarm: _alarm)
                        : _getActivatedSwitch(
                            activated: _alarm.activated,
                            index: index,
                          ),
                  ],
                ),
                height: _size.height * 0.1,
              )
            : const Text('');
      },
      separatorBuilder: (context, index) => const Divider(
        color: CupertinoColors.systemFill,
        thickness: 2,
      ),
      itemCount: _localData.alarmListState.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
    );
  }

  @override
  void initState() {
    super.initState();
    // 로컬 저장소 객체 초기화
    _localData = LocalData();
    _localData.init();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 size
    final _size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: _getLeadingButton(),
        middle: const Text('알람'),
        trailing: _getTrailingButton(),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _getListView(_size),
            ),
          ],
        ),
      ),
    );
  }
}
