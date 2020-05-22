import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';

class eat {
  final int id;
  final String image_path;
  final String text;

  eat({this.id, this.image_path, this.text});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': image_path,
      'text': text,
    };
  }
}

class viewimage extends StatefulWidget {
  @override
  State<viewimage> createState() => _viewimageState();
}

class _viewimageState extends State<viewimage> {
  String path;
  File filetext;
  int tmpI = 0;

  @override
  Widget build(BuildContext context) {
    //readDB(7);
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

  void getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);

    if (!filetext.existsSync()) {
      print("file not found, creating file");
      await filetext.create();
      await filetext.writeAsString('0');
    }

    tmpI++;

    await image.copy('$path/Pictures/$tmpI.jpg');
    await filetext.writeAsString('$tmpI');
    String text = "hello";
    insertDB(tmpI, '$path/Pictures/$tmpI.jpg', text);

    setState(() {
      tmpI;
      print(tmpI);
    });
  }

  void gettmpI() async {
    SharedPreferences path_prefs = await SharedPreferences.getInstance()
        .whenComplete(() => print('complete'));

    path = path_prefs.getString('path');
    if (path == null) {
      //требуется при первом запуске, тк запись происходит позже чем чтение
      Directory tempDir = await getExternalStorageDirectory();
      path = tempDir.path.toString();
    }

    filetext = new File('$path/my_file.txt');
    String number = await filetext.readAsString();

    setState(() {
      tmpI = int.parse(number);
      print('tmpI= $tmpI');
    });
  }

  @override
  void initState() {
    super.initState();
    gettmpI();
  }
}
