import 'package:flutter/cupertino.dart';

class EditPage extends StatefulWidget {
  const EditPage({Key? key}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('알람 편집'),
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
        child: Text('edit'),
      ),
    );
  }
}
