import 'package:flutter/cupertino.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('알람 설정'),
        leading: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {},
          child: const Text('저장'),
        ),
      ),
      child: const Center(
        child: Text('add'),
      ),
    );
  }
}
