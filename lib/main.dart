import 'package:flutter/material.dart';
import 'package:test_flutter/ControllerFieldMask.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

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
  FieldMaskController phoneFieldController;

  @override
  void initState() {
    super.initState();

    phoneFieldController = FieldMaskController("+7 (___)___-__-__", "_", "0123456789")..addRemoveInsertPrefix("7");
    phoneFieldController.initState();
  }

  @override
  void dispose() {
    super.dispose();

    phoneFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              key: Key("phone-field"),
              keyboardType: TextInputType.phone,
              autofocus: true,
              controller: phoneFieldController.controller,
            )
          ],
        ),
      ),
    );
  }
}
