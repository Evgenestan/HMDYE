// Flutter code sample for AppBar

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';

String path =
    "/storage/emulated/0/Android/data/com.example.flutterappfirst/files"; // дикий костыль, тут проблема так же упирается в то, что я не до конца понимаю как работать с асинхронными функциями и в итоге путь требуется раньше, чем заканчивает работу асинхронная функция
void getPath() async {
  Directory tempDir = await getExternalStorageDirectory();
  path = tempDir.path.toString();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  getPath();
  print('main');
  runApp(MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Сколько ты съел';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatelessWidget(),
    );
  }
}

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
final SnackBar snackBar = const SnackBar(content: Text('Информация'));

Future<void> getImage1() async {
  int intnumber = 0;
  File image = await ImagePicker.pickImage(source: ImageSource.camera);

  final File file = new File('$path/my_file.txt');
  if (!file.existsSync()) {
    print("file not found, creating file");
    File file = new File('$path/my_file.txt');
    await file.writeAsString('create');
    await file.copy('$path/my_file.txt');
    await file.writeAsString('0');
  }

  String number = await file.readAsString();
  intnumber = int.parse(number);
  intnumber++;

  await image.copy('$path/Pictures/$intnumber.jpg');
  await file.copy('$path/my_file.txt');

  await file.writeAsString('$intnumber');
}

void openPage(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(
    builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Вторая страница'),
        ),
        body: const Center(
          child: Text(
            'This is the next page',
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    },
  ));
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Главная'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            tooltip: 'О приложении',
            onPressed: () {
              scaffoldKey.currentState.showSnackBar(snackBar);
            },
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            tooltip: 'Далее',
            onPressed: () {
              openPage(context);
            },
          ),
        ],
      ),
      body: Center(child: new viewimage()),
    );
  }
}

class viewimage extends StatefulWidget {
  @override
  State<viewimage> createState() => _viewimageState();
}

class _viewimageState extends State<viewimage> {
  final File filetext = new File('$path/my_file.txt');
  int tmpI = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    gettmpI();
  }

  void gettmpI() async {
    String number = await filetext.readAsString();

    setState(() {
      tmpI = int.parse(number);
      print('tmpI= $tmpI');
    });
  }

  void getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);

    //final File filetext = new File('$path/my_file.txt');
    if (!filetext.existsSync()) {
      print("file not found, creating file");
      //File file = new File('$path/my_file.txt');
      await filetext.writeAsString('create');
      await filetext.copy('$path/my_file.txt');
      await filetext.writeAsString('0');
    }

    /*String number = await filetext.readAsString();
    tmpI = int.parse(number);*/
    tmpI++;

    await image.copy('$path/Pictures/$tmpI.jpg');
    //await filetext.copy('$path/my_file.txt');

    await filetext.writeAsString('$tmpI');

    setState(() {
      tmpI;
      print(tmpI);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            getImage(); //функция для получения и сохранения новой фотографии, после её работы как раз нужно обновить список с фотографиями
          },
          child: Icon(Icons.camera_alt),
          backgroundColor: Colors.blue,
        ),
        body: new ListView.builder(itemBuilder: (context, i) {
          if (i < tmpI) {
            // 3 потому что у меня в данный момент сохранено 3 фото, потом тут будет переменная в которой будет содержать количетсво фото
            print('$tmpI tmpI');
            File tempImage = File('$path/Pictures/${i + 1}.jpg');

            return new ListTile(
                title: Row(
              children: <Widget>[
                new Image.file(
                  tempImage,
                  height: 200,
                ),
                Expanded(
                  child: new Text('подпись ${i + 1}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kanit(
                        fontSize: 30,
                      )),
                )
              ],
            ));
          } else {
            return null;
          }
        }));
  }
}
