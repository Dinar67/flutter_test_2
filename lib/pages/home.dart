import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/pages/NavBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List toDoList = [];
  String _userToDo = "";
  final controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    toDoList.addAll(["Buy milk", "Wash dishes", "Testing"]);
  }

  void _menuOpen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Меню"),
          centerTitle: true,
          backgroundColor: Colors.grey,
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Navbar(),
      appBar: AppBar(
        title: Text(
          "Лист c вещами",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("items").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return const Center(child: Text("Нет записей!"));
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: Key(snapshot.data!.docs[index].id),
                child: Card(
                  child: ListTile(
                    title: Text(snapshot.data?.docs[index].get('item')),
                    trailing:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.amberAccent,
                          onPressed: () async {
                            controller.text =
                                snapshot.data?.docs[index].get('item');
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Редатировать элемент"),
                                    content: TextField(
                                      controller: controller,
                                      onChanged: (String value) {
                                        _userToDo = value;
                                      },
                                    ),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection("items")
                                                .doc(snapshot
                                                    .data!.docs[index].id)
                                                .update(
                                                    {'item': controller.text});
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Изменить"))
                                    ],
                                  );
                                });
                          }),
                      IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.amberAccent,
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("items")
                                .doc(snapshot.data!.docs[index].id)
                                .delete();
                          }),
                    ]),
                  ),
                ),
                onDismissed: (direction) {
                  FirebaseFirestore.instance
                      .collection("items")
                      .doc(snapshot.data!.docs[index].id)
                      .delete();
                },
              );
            },
            itemCount: snapshot.data?.docs.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Добавить элемент"),
                  content: TextField(
                    onChanged: (String value) {
                      _userToDo = value;
                    },
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('items')
                              .add({'item': _userToDo});
                          Navigator.of(context).pop();
                          _userToDo = "";
                        },
                        
                        child: Text("Добавить"))
                  ],
                );
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.amberAccent,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
