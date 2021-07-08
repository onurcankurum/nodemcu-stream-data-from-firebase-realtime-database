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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Meşe Bilişim Açma Kapama Tuşu'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
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
