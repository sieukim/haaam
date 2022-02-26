import 'package:flutter/cupertino.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('알람'),
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            Navigator.of(context).pushNamed('/add');
          },
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: const Center(
        child: Text('home'),
      ),
    );
  }
}