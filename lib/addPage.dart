import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haaam/alarm.dart';
import 'package:haaam/localData.dart';
import 'package:intl/intl.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  // 로컬 저장소 객체
  late LocalData _localData;

  // 알람 제목 CupertinoTextField controller
  late TextEditingController _textEditingController;

  // 알람 시간 리스트
  final List<String> _timeList = [];

  // 현재 시간
  final _currentTime = DateTime.now();

  // CupertinoDatePicker가 나타내는 시간
  DateTime _pickedTime = DateTime.now();

  // 저장 버튼 비활성화 정보
  bool _disabled = true;

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
  _onPressedSave() async {
    // 알람 객체
    Alarm alarm = Alarm(
      _textEditingController.text,
      _timeList.join(','),
      true,
    );
    // 로컬 저장소에 저장
    _localData.save(
      alarm: alarm,
      context: context,
    );
    // 저장된 알람 객체를 반환하며 네비게이션
    Navigator.of(context).pop({'alarm': alarm, 'type': 'save'});
  }

  // 네비게이션 바 내 trailing 버튼 객체를 반환하는 함수
  _getTrailingButton() {
    // 버튼 비활성화 정보 갱신
    setState(() {
      if (_timeList.isEmpty || _textEditingController.text.isEmpty) {
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
      disabledColor: CupertinoColors.systemFill,
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
      if (!_timeList.contains(time)) {
        _timeList.add(time);
        _timeList.sort();
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
      controller: _textEditingController,
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
        var time = _timeList[index];

        return _timeList.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(time),
                  CupertinoButton(
                    child: const Icon(CupertinoIcons.minus_circle),
                    onPressed: () {
                      setState(() {
                        _timeList.remove(time);
                      });
                    },
                  ),
                ],
              )
            : const Text('시간을 추가해주세요');
      },
      itemCount: _timeList.length,
      padding: const EdgeInsets.all(10),
      separatorBuilder: (context, index) => const Divider(
        color: CupertinoColors.systemFill,
        thickness: 2,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 로컬 저장소 객체 초기화
    _localData = LocalData();
    _localData.init();
    // 알람 제목 controller
    _textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 size
    final _size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: _getLeadingButton(),
        middle: const Text('알람 추가'),
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
          ],
        ),
      ),
    );
  }
}
