import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterappfirst/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';

File filetext;
var path;
var tmpI = 0;

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

class inputDate extends StatefulWidget {
  @override
  State<inputDate> createState() => _inputDateState();
}

class viewimage extends StatefulWidget {
  int day = new DateTime.now().day;
  int month = new DateTime.now().month;
  int year = new DateTime.now().year;

  @override
  State<viewimage> createState() => _viewimageState();
}

class _inputDateState extends State<inputDate> {
  File image;
  String inserttext = "Описание отсутствует";

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('New food'),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(8.0),

           child:  Container(

                 decoration: BoxDecoration(
                     color: Colors.white,
                     boxShadow: [
                       new BoxShadow(
                         color: Colors.grey,
                         blurRadius: 25,
                         offset: Offset(
                           2, // Move to right 10  horizontally
                           2, // Move to bottom 10 Vertically
                         ),
                       )
                     ],
                     borderRadius: BorderRadius.circular(20)
                 ),
                 child: Padding(
                   padding: EdgeInsets.all(8.0),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: <Widget>[
                       Container(
                         width: 400,
                         child: Padding(
                           padding: EdgeInsets.all(2),
                           child: GestureDetector(
                             onTap: () async {
                               await getImage();
                             },
                             child: ClipRRect(
                                 borderRadius: BorderRadius.circular(50),

                                 child: image == null
                                     ? Image.asset(
                                   "assets/images/camera3.png",
                                   color: Colors.white70,
                                   colorBlendMode: BlendMode.hardLight,
                                 )
                                     : Image.file(image,fit: BoxFit.fill,)
                             ),
                           ),
                         ),
                       ),
                       Container(
                         child: Padding(
                           padding: EdgeInsets.only(left: 2, top: 10, right: 2),
                           child: TextFormField(
                             onChanged: (input) => inserttext = input,
                             decoration:
                             InputDecoration(hintText: "Describe your dish"),
                           ),
                         ),
                       ),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.end,
                         children: <Widget>[
                           Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: RaisedButton(
                               onPressed: () async {
                                 if (image != null) {
                                   if (!filetext.existsSync()) {
                                     print("file not found, creating file");
                                     await filetext.create();
                                     await filetext.writeAsString('0');
                                   }

                                   tmpI++;

                                   await image.copy('$path/Pictures/$tmpI.jpg');
                                   await filetext.writeAsString('$tmpI');

                                   insertDB(
                                       tmpI, '$path/Pictures/$tmpI.jpg', inserttext);
                                 } else {
                                   print('image null');
                                 }
                                 Navigator.pop(context);
                               },
                               child: Text('Готово'),
                             ),
                           )
                         ],
                       )
                     ],
                   ),
                 ),
               )

        )
    );
  }

  void getImage() async {
    await ImagePicker.pickImage(
            source: ImageSource.camera, maxWidth: 480, maxHeight: 640)
        .then((value) {
      setState(() {
        image = value;
      });
    });
  }
}

class _viewimageState extends State<viewimage> {
  var now = new DateTime.now().toIso8601String();

  String imagePath = "";

  String text = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => inputDate()),
            ).then((value) {
              setState(() {
                tmpI;
              });
            });
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
        body: new ListView.builder(
            //itemCount: tmpI,
          cacheExtent: 10000,
            physics:  const AlwaysScrollableScrollPhysics (),
            itemBuilder: (context, i) {
          if (i < tmpI) {
            return FutureBuilder(
              future: readDB(i),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    File tempImage = File(snapshot.data.image_path);
                    var text1 = snapshot.data.text;

                    return new Padding(
                        padding: EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              new BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                                offset: Offset(
                                  2, // Move to right 10  horizontally
                                  2, // Move to bottom 10 Vertically
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(

                            children: <Widget>[
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: new Image.file(
                                    tempImage,
                                    height: 200,
                                    fit: BoxFit.fill,

                                  )


                              )
                              ,
                              Expanded(
                                child: new Text(text1,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.kanit(
                                      fontSize: 30,
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                    );

                  default:
                    return Text('');
                }
              },
            );
          } else {
            return null;
          }
        }));
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
