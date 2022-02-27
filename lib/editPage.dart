import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPage extends StatefulWidget {
  final Map<String, dynamic>? alarm;

  const EditPage({Key? key, this.alarm}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  // 알람
  late Map<String, dynamic> _alarm;

  // 알람 객체를 문자열로 변환
  late String _alarmString;

  // 알람 제목 CupertinoTextField controller
  late TextEditingController _textEditingController;

  // 알람 제목
  late String _alarmTitle;

  // 로컬 저장소에 저장된 알람 목록
  List<String> _alarmListLocal = [];

  // 로컬 저장소에 저장된 알람 제목 목록
  late List<String> _alarmTitleLocal;

  // 알람 시간 리스트
  List<String> _timeList = [];

  // 현재 시간
  final _currentTime = DateTime.now();

  // CupertinoDatePicker가 나타내는 시간
  DateTime _pickedTime = DateTime.now();

  // CupertinoDatePicker onDateTimeChanged 핸들러
  _onDateTimeChanged(DateTime time) {
    setState(() {
      _pickedTime = time;
    });
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

  // 경고 문구 띄우기
  _showCupertinoDialog(String message) {
    // 경고 문구
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('확인'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // 알람 저장 버튼 onPressed 핸들러
  _onPressedSave() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    setState(() {
      // 알람 제목
      _alarmTitle = _textEditingController.text;
    });

    if (_alarmTitle != _alarm['title'] &&
        _alarmTitleLocal.contains(_alarmTitle)) {
      _showCupertinoDialog('중복된 이름입니다.');
    } else if (_alarmTitle.isEmpty) {
      _showCupertinoDialog('알람 이름을 입력해주세요.');
    } else {
      // 로컬 저장소 알람 목록에서 기존 알람 제거
      _alarmListLocal.remove(_alarmString);

      // 로컬 저장소 알람 제목 목록에서 기존 알람 제목 제거
      _alarmTitleLocal.remove(_alarm['title'].toString());

      // 편집된 알람
      var _newAlarm =
          '{"title": "$_alarmTitle", "timeList": "$_timeList", "activated": "true"}';

      // 로컬 저장소에 알람 목록에 현재 알람 추가
      await _prefs.setStringList('alarmList', [..._alarmListLocal, _newAlarm]);

      // 로컬 저장소에 알람 제목 목록에 현재 알람 제목 추가
      await _prefs
          .setStringList('alarmTitleList', [..._alarmTitleLocal, _alarmTitle]);

      Navigator.of(context).pop({'alarm': _newAlarm, 'type': 'edit'});
    }
  }

  // 알람 삭제 버튼 onPressed 핸들러
  _onPressedDelete() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    setState(() {
      // 로컬 저장소에 저장된 알람 목록
      _alarmListLocal.remove(_alarmString);

      // 로컬 저장소에 저장된 제목 목록
      _alarmTitleLocal.remove(_alarm['title']);
    });

    _prefs.setStringList('alarmList', _alarmListLocal);
    _prefs.setStringList('alarmTitleList', _alarmTitleLocal);

    Navigator.of(context).pop({'alarm': _alarm, 'type': 'delete'});
  }

  // 로컬 저장소에 저장된 알람 목록 가져오기
  _loadAlarmList() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    // 로컬 저장소에 저장된 알람 목록
    _alarmListLocal = _prefs.getStringList('alarmList') ?? [];

    // 로컬 저장소에 저장된 알람 제목 목록
    _alarmTitleLocal = _prefs.getStringList('alarmTitleList') ?? [];
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      // 부모로부터 전달받은 알람 객체
      _alarm = widget.alarm!;

      // 알람 문자열
      _alarmString =
          '{"title": "${_alarm['title']}", "timeList": "${_alarm['timeList']}", "activated": "${_alarm['activated']}"}';

      // 알람 제목 controller
      _textEditingController = TextEditingController(text: _alarm['title']);

      // 알람 시간 목록
      String _timeListString = _alarm['timeList'].toString();
      _timeList =
          _timeListString.substring(1, _timeListString.length - 1).split(',');
    });
    _loadAlarmList();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 size
    final _size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('알람 편집'),
        leading: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            Navigator.of(context).pop(_alarm);
          },
          child: const Text('취소'),
        ),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: _onPressedSave,
          child: const Text('저장'),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: _size.height * 0.25,
                  width: _size.width * 0.8,
                  child: CupertinoDatePicker(
                    initialDateTime: _currentTime,
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: false,
                    onDateTimeChanged: _onDateTimeChanged,
                  ),
                ),
                CupertinoButton(
                  child: const Text('추가'),
                  onPressed: _onPressedAdd,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
            ),
            CupertinoTextField(
              placeholder: '알람 이름',
              controller: _textEditingController,
              keyboardType: TextInputType.text,
              padding: const EdgeInsets.all(9),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
            ),
            Expanded(
              child: ListView.separated(
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
              ),
            ),
            CupertinoButton.filled(
              child: const Text(
                '알람 삭제',
              ),
              onPressed: _onPressedDelete,
            ),
          ],
        ),
      ),
    );
  }
}
