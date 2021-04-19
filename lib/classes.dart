import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:st_michael/class_page.dart';
import 'package:st_michael/components/class_item.dart';
import 'package:st_michael/components/loading.dart';
import 'package:st_michael/main.dart';
import 'package:st_michael/theme/themecolor.dart';

class ClassesPage extends StatefulWidget {
  @override
  _ClassesPageState createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  bool loading = false;
  List<QueryDocumentSnapshot> classesReference = [];

  _getClasses() async {
    setState(() {
      loading = true;
    });

    classes.orderBy('name', descending: true).get().then((querySnapshot) {
      setState(() {
        loading = false;
        classesReference = querySnapshot.docs;
      });
    }).catchError((error) {
      setState(() {
        loading = false;
      });
    });
  }

  void _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  void initState() {
    _requestStoragePermission();
    _getClasses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: background,
        appBar: (AppBar(
          backgroundColor: primary,
          title: Text("ምድብ"),
          actions: [
            InkWell(
                onTap: () {
                  _getClasses();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.refresh),
                ))
          ],
        )),
        // drawer: MenuDrawer(),
        body: SafeArea(
            child: !loading
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Material(
                      child: Container(
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(top: 10),
                                child: ListView.builder(
                                  itemCount: classesReference.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      ClassPage(
                                                          ref: classesReference[
                                                              index])));
                                        },
                                        child: ClassItem(
                                          ref: classesReference[index],
                                        ));
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                : Container(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: Loading(context)))));
  }
}
