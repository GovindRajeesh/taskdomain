import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory document = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<String>("tasks");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskDomain',
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
        primarySwatch: Colors.orange,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: splash(),
    );
  }
}

class splash extends StatefulWidget {
  @override
  _splashState createState() => _splashState();
}

class _splashState extends State<splash> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 5),
        () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => taskspage())));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 230.0, left: 25.0, bottom: 100.0),
            child: Text(
              "Taskdomain",
              style: TextStyle(fontSize: 50, color: Colors.white),
            ),
          ),
          Container(
            child: SpinKitSpinningCircle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class taskspage extends StatefulWidget {
  @override
  _taskspageState createState() => _taskspageState();
}

class _taskspageState extends State<taskspage> {
  Box<String> taskbox;
  var tasknumber;
  final TextEditingController name = TextEditingController();
  final TextEditingController desc = TextEditingController();
  var formkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    taskbox = Hive.box<String>("tasks");
    setState(() {
      tasknumber = taskbox.keys.toList().length.toString();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("$tasknumber tasks to do"),
          actions: <Widget>[
            IconButton(
                tooltip: "Delete all the tasks",
                icon: Icon(Icons.delete_sweep),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Delete all tasks"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                    "Are you sure you want to delete all the tasks?"),
                                FlatButton(
                                    onPressed: () {
                                      taskbox.deleteAll(taskbox.keys);
                                      Navigator.pop(context);
                                      setState(() {
                                        tasknumber = taskbox.keys
                                            .toList()
                                            .length
                                            .toString();
                                      });
                                    },
                                    child: Text("Yes")),
                                FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("No")),
                              ],
                            ),
                          ));
                })
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.bookmark),
                title: Text("Tasks to do"),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => taskspage())),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text("About the app"),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => aboutApp())),
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text("Exit"),
                onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text("Exit!"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  "Are you sure you want to exit this application?"),
                              FlatButton(
                                child: Text("Yes"),
                                onPressed: () {
                                  exit(0);
                                },
                              ),
                              FlatButton(
                                child: Text("No"),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        )),
              ),
            ],
          ),
        ),
        body: Row(
          children: <Widget>[
            Expanded(
                child: ValueListenableBuilder(
                    valueListenable: taskbox.listenable(),
                    builder: (context, index, _) {
                      return ListView.separated(
                          itemBuilder: (context, index) {
                            if (taskbox.keys.toList().length == 0) {
                              return Text(
                                  "Press the add button below to add tasks");
                            } else {
                              final key = taskbox.keyAt(index);
                              final value = taskbox.get(key);
                              return ListTile(
                                title: Text("$key"),
                                subtitle: Text("$value"),
                                trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: Text("Delete task"),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                        "Do you want to delete task ${taskbox.keyAt(index)}?"),
                                                    FlatButton(
                                                      child: Text("No"),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    FlatButton(
                                                      child: Text("Yes"),
                                                      onPressed: () {
                                                        taskbox.delete(taskbox
                                                            .keyAt(index));
                                                        setState(() {
                                                          tasknumber = taskbox
                                                              .keys
                                                              .toList()
                                                              .length
                                                              .toString();
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ));
                                    }),
                              );
                            }
                          },
                          separatorBuilder: (_, index) => Divider(),
                          itemCount: taskbox.keys.toList().length);
                    }))
          ],
        ),
        floatingActionButton: FloatingActionButton(
            tooltip: "Add a task",
            child: Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                      title: Text("Add Task"),
                      content: Form(
                        key: formkey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              controller: name,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return "You should enter name !";
                                }
                                ;
                              },
                              decoration: InputDecoration(
                                hintText: "Task name",
                              ),
                            ),
                            TextField(
                              controller: desc,
                              decoration: InputDecoration(
                                hintText: "Task description",
                              ),
                            ),
                            FlatButton(
                                onPressed: () {
                                  final key = name.text;
                                  final value = desc.text;
                                  if (formkey.currentState.validate()) {
                                    taskbox.put(key, value);
                                    Navigator.pop(context);
                                    setState(() {
                                      tasknumber = taskbox.keys
                                          .toList()
                                          .length
                                          .toString();
                                    });
                                  }
                                },
                                child: Text("Add task")),
                            FlatButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      )));
            }));
  }
}

class aboutApp extends StatefulWidget {
  @override
  _aboutAppState createState() => _aboutAppState();
}

class _aboutAppState extends State<aboutApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About the app"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.bookmark),
              title: Text("Tasks"),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => taskspage())),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("About the app"),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => aboutApp())),
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text("Exit"),
              onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text("Exit!"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                "Are you sure you want to exit this application?"),
                            FlatButton(
                              child: Text("Yes"),
                              onPressed: () {
                                exit(0);
                              },
                            ),
                            FlatButton(
                              child: Text("No"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      )),
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Image(image: AssetImage('images/icon2.png')),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 250.0),
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40))),
            child: Text(
              "App Name:Taskdomain\n\nWritten in:Flutter(Dart)\n\nCreated by:Govind Rajeesh\n\n",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
