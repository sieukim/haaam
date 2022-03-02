import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:haaam/globalVariable.dart';
import 'package:haaam/runAlarm.dart';

import 'addPage.dart';
import 'editPage.dart';
import 'mainPage.dart';

void main() {
  runApp(const MyApp());
  runAlarm();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemOrange,
      ),
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      initialRoute: '/',
      routes: {
        '/': (_) => const MainPage(),
        '/add': (_) => const AddPage(),
        '/edit': (_) => const EditPage(),
        '/alarm': (_) => const RunAlarm(),
      },
      navigatorKey: GlobalVariable.navigatorState,
    );
  }
}
