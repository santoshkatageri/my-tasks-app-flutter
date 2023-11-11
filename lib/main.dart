import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'N1jpHEo0Vq83tJxE8NwKrYa9uGobBjQWO9goI83U';
  final keyClientKey = 'DWqsPKCHf69l7KCHJVwALUP55a0QhK4mGmlz4dit';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TaskController = TextEditingController();
  final TaskControllerdescription = TextEditingController();

  void addTask() async {
    if (TaskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Empty title"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if (TaskControllerdescription.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Empty Description"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveTask(TaskController.text,TaskControllerdescription.text);
    setState(() {
      TaskController.clear();
      TaskControllerdescription.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Parse Task List"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: TaskController,
                      decoration: InputDecoration(
                          labelText: "Task",
                          labelStyle: TextStyle(color: Colors.blueAccent)),
                    )
                  ),
                  Expanded(
                    child: TextField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: TaskControllerdescription,
                      decoration: InputDecoration(
                          labelText: "Description",
                          labelStyle: TextStyle(color: Colors.blueAccent)),
                    )
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        onPrimary: Colors.white,
                        primary: Colors.blueAccent,
                      ),
                      onPressed: addTask,
                      child: Text("ADD")),
                ],
              )),
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: getTask(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator()),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error..."),
                          );
                        }
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("No Data..."),
                          );
                        } else {
                          return ListView.builder(
                              padding: EdgeInsets.only(top: 10.0),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                //*************************************
                                //Get Parse Object Values
                                final varTask = snapshot.data![index];
                                final varTitle = varTask.get<String>('title')!;
                                final varDescription = varTask.get<String>('description')!;
                                final varDone =  varTask.get<bool>('done')!;
                                //*************************************

                                return ListTile(
                                  title: Text(varTitle),
                                  leading: CircleAvatar(
                                    child: Icon(
                                        varDone ? Icons.check : Icons.error),
                                    backgroundColor:
                                        varDone ? Colors.green : Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  subtitle: Text(varDescription),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                          value: varDone,
                                          onChanged: (value) async {
                                            await updateTask(
                                                varTask.objectId!, value!);
                                            setState(() {
                                              //Refresh UI
                                            });
                                          }),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () async {
                                          await deleteTask(varTask.objectId!);
                                          setState(() {
                                            final snackBar = SnackBar(
                                              content: Text("Task deleted!"),
                                              duration: Duration(seconds: 2),
                                            );
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(snackBar);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                );
                              });
                        }
                    }
                  }))
        ],
      ),
    );
  }

  Future<void> saveTask(String title, String description) async {
    //await Future.delayed(Duration(seconds: 1), () {});
    final task = ParseObject('Task')..set('title', title)..set('description', description)..set('done', false);
    await task.save();
  }

  Future<List<ParseObject>> getTask() async {
    //await Future.delayed(Duration(seconds: 2), () {});
    //return [];
    QueryBuilder<ParseObject> queryTask =
        QueryBuilder<ParseObject>(ParseObject('Task'));
    final ParseResponse apiResponse = await queryTask.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> updateTask(String id, bool done) async {
    //await Future.delayed(Duration(seconds: 1), () {});
     //var Task = ParseObject('Task')
     var task = ParseObject('Task')
      ..objectId = id
      ..set('done', done);
    await task.save();
  }

  Future<void> deleteTask(String id) async {
   //await Future.delayed(Duration(seconds: 1), () {});
   //var Task = ParseObject('Task')..objectId = id;
   var task = ParseObject('Task')..objectId = id;
    await task.delete();
  }
}