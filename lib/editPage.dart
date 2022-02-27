import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haaam/alarm.dart';
import 'package:intl/intl.dart';

import 'localData.dart';

class EditPage extends StatefulWidget {
  final Alarm? alarm;

  const EditPage({Key? key, this.alarm}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  // 로컬 저장소 객체
  late LocalData _localData;

  // 부모로부터 전달받은 현재 알람 객체
  late Alarm _currentAlarm;

  // 새로운 알람 제목 CupertinoTextField controller
  late TextEditingController _newTextEditingController;

  // 새로운 알람 timeList
  late List<String> _newTimeList = [];

  // 현재 시간
  final _currentTime = DateTime.now();

  // CupertinoDatePicker가 나타내는 시간
  DateTime _pickedTime = DateTime.now();

  // 저장 버튼 비활성화 정보
  bool _disabled = false;

  // 중간 삽입 padding 객체를 반환하는 함수
  _getPadding() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
    );
  }

  // 네비게이션 바 내 leading 버튼 객체를 반환하는 함수
  _getLeadingButton() {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: () {
        Navigator.of(context).pop({'type': 'cancel', 'alarm': null});
      },
      child: const Text('취소'),
    );
  }

  // 알람 저장 버튼 onPressed 핸들러
  _onPressedSave() {
    // 기존 알람 객체
    Alarm previousAlarm = _currentAlarm;
    // 편집된 알람 객체
    Alarm nextAlarm = Alarm(
      _newTextEditingController.text,
      _newTimeList.join(','),
      _currentAlarm.activated,
    );
    // 로컬 저장소 편집
    _localData.edit(
      previousAlarm: previousAlarm,
      nextAlarm: nextAlarm,
      context: context,
    );
    // 편집된 알람 객체를 반환하며 네비게이션
    Navigator.of(context).pop({
      'alarm': nextAlarm,
      'type': 'edit',
    });
  }

  // 네비게이션 바 내 trailing 버튼 객체를 반환하는 함수
  _getTrailingButton() {
    // 버튼 비활성화 정보 갱신
    setState(() {
      if (_newTimeList.isEmpty || _newTextEditingController.text.isEmpty) {
        _disabled = true;
      } else {
        _disabled = false;
      }
    });
    // 버튼 반환
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: _disabled ? null : _onPressedSave,
      child: const Text('저장'),
    );
  }

  // CupertinoDatePicker onDateTimeChanged 핸들러
  _onDateTimeChanged(DateTime time) {
    setState(() {
      _pickedTime = time;
    });
  }

  // CupertinoDatePicker 객체를 반환하는 함수
  _getTimePicker(Size _size) {
    return SizedBox(
      height: _size.height * 0.25,
      width: _size.width * 0.8,
      child: CupertinoDatePicker(
        initialDateTime: _currentTime,
        mode: CupertinoDatePickerMode.time,
        use24hFormat: false,
        onDateTimeChanged: _onDateTimeChanged,
      ),
    );
  }

  // 시간 추가 버튼 onPressed 핸들러
  _onPressedAdd() {
    var ampm = _pickedTime.hour < 12 ? '오전' : '오후';
    var time = DateFormat('$ampm hh:mm').format(_pickedTime);

    setState(() {
      // 시간 목록
      if (!_newTimeList.contains(time)) {
        _newTimeList.add(time);
        _newTimeList.sort();
      }
    });
  }

  // 시간 추가 버튼 객체를 반환하는 함수
  _getAddButton() {
    return CupertinoButton(
      child: const Text('추가'),
      onPressed: _onPressedAdd,
    );
  }

  // 알람 제목을 입력 CupertinoTextField 객체를 반환하는 함수
  _getTextField() {
    return CupertinoTextField(
      placeholder: '알람 이름',
      controller: _newTextEditingController,
      keyboardType: TextInputType.text,
      padding: const EdgeInsets.all(9),
      onChanged: (value) {
        setState(
          () {
            if (value.isEmpty) {
              _disabled = true;
            } else {
              _disabled = false;
            }
          },
        );
      },
    );
  }

  // 알람 timeList 리스트 뷰
  _getListView() {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var time = _newTimeList[index];

        return _newTimeList.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(time),
                  CupertinoButton(
                    child: const Icon(CupertinoIcons.minus_circle),
                    onPressed: () {
                      setState(() {
                        _newTimeList.remove(time);
                      });
                    },
                  ),
                ],
              )
            : const Text('시간을 추가해주세요');
      },
      itemCount: _newTimeList.length,
      padding: const EdgeInsets.all(10),
      separatorBuilder: (context, index) => const Divider(
        color: CupertinoColors.systemFill,
        thickness: 2,
      ),
    );
  }

  // 알람 삭제 버튼 onPressed 핸들러
  _onPressedRemove() {
    _localData.remove(alarm: _currentAlarm);
    // 삭제된 알람 객체를 반환하며 네비게이션
    Navigator.of(context).pop({'alarm': _currentAlarm, 'type': 'remove'});
  }

  // 알람 삭제 버튼 객체를 반환하는 함수
  _getRemoveButton() {
    return CupertinoButton.filled(
      child: const Text(
        '알람 삭제',
      ),
      onPressed: _onPressedRemove,
    );
  }

  @override
  void initState() {
    super.initState();
    // 로컬 저장소 객체 초기화
    _localData = LocalData();
    _localData.init();
    // 부모로부터 전달받은 알람 객체
    _currentAlarm = widget.alarm!;
    // 새로운 알람 제목 controller
    _newTextEditingController =
        TextEditingController(text: _currentAlarm.title);
    // 새로운 알람 timeList
    _newTimeList = _currentAlarm.timeList.split(',');
  }

  @override
  Widget build(BuildContext context) {
    // 화면 size
    final _size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: _getLeadingButton(),
        middle: const Text('알람 편집'),
        trailing: _getTrailingButton(),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _getPadding(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getTimePicker(_size),
                _getAddButton(),
              ],
            ),
            _getPadding(),
            _getTextField(),
            _getPadding(),
            Expanded(
              child: _getListView(),
            ),
            _getRemoveButton(),
          ],
        ),
      ),
    );
  }
}
