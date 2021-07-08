import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Meşe Bilişim Açma Kapama Tuşu'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isBusy = false;
  final databaseReference = FirebaseDatabase.instance.reference();

  // burada databaseten servo motorun müsait olup olmadığını çekiyoruz eğer
  //müsait ise false değeri değil ise true değeri dönüyor

  void _incrementCounter() {
    databaseReference.child("led").once().then((DataSnapshot data) {
      if (_isBusy == false) {
        databaseReference.child("led").set({'led': true}).onError(
            (error, stackTrace) => print("işlem gerçekleşmedi"));
        setState(() {
          _isBusy = data.value['led'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    databaseReference.child("led").once().then((DataSnapshot data) {
      _isBusy = data.value['led'];
    });
    print(_isBusy);
    Query comments = databaseReference.orderByChild('time').limitToLast(10);

    /*  databaseReference.child("led").once().then((DataSnapshot data) {
      setState(() {
        _isBusy = data.value['led'];
      });
    });*/
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        //burada ise nodemcu yu dinliyoruz
        child: StreamBuilder(
            stream: comments.onChildChanged,
            builder: (BuildContext context, snapshot) {
              databaseReference.child("led").once().then((DataSnapshot data) {
                _isBusy = data.value['led'];
              });
              if (snapshot.hasData) {
                return GestureDetector(
                  onTap: () {
                    if (_isBusy == true) {
                      print("basılıyor");
                    } else {
                      _incrementCounter();
                    }
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    child: CircleAvatar(
                        backgroundColor: _isBusy ? Colors.brown : Colors.amber,
                        child: _isBusy
                            ? Text("aç/kapa")
                            : Text(
                                'işlem gerçekleştiriliyor',
                              )),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("hata oluştu internete bağlı mısınız?");
              } else {
                return GestureDetector(
                  onTap: () {
                    if (_isBusy == true) {
                      print("basılıyor");
                    } else {
                      _incrementCounter();
                    }
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    child: CircleAvatar(
                        backgroundColor: _isBusy ? Colors.brown : Colors.amber,
                        child: _isBusy
                            ? Text('işlem gerçekleştiriliyor')
                            : Text("aç/kapa")),
                  ),
                );
              }
            }),
      ),
    );
  }
}

