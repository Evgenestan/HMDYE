// Flutter code sample for AppBar

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';
import 'imageList.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  getPath();
  print('main');
  runApp(MyApp());
}

// "/storage/emulated/0/Android/data/com.example.flutterappfirst/files"; // дикий костыль, тут проблема так же упирается в то, что я не до конца понимаю как работать с асинхронными функциями и в итоге путь требуется раньше, чем заканчивает работу асинхронная функция // исправлено
String path;

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

final SnackBar snackBar = const SnackBar(content: Text('Приложение создано для помощи в отслеживании количества еды'));

void getPath() async {
  Directory tempDir = await getExternalStorageDirectory();
  path = tempDir.path.toString();
  print(path);
  SharedPreferences path_pref = await SharedPreferences.getInstance();
  path_pref.setString('path', path);
  print('SharedPreferens path = $path');
}






/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Food counter';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatelessWidget(),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Your food'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            tooltip: 'О приложении',
            onPressed: () {
              scaffoldKey.currentState.showSnackBar(snackBar);
            },
          ),

        ],
      ),
      body: Center(child: new viewimage()),
    );
  }
}
