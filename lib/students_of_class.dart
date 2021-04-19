import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:st_michael/components/student_item.dart';
import 'package:st_michael/main.dart';
import 'package:st_michael/theme/themecolor.dart';
import 'package:csv/csv.dart';
import 'components/loading.dart';

class StudentsOfClass extends StatefulWidget {
  StudentsOfClass({Key key, this.level}) : super(key: key);
  final String level;
  @override
  _StudentsOfClassState createState() => _StudentsOfClassState();
}

class _StudentsOfClassState extends State<StudentsOfClass> {
  bool loading = false;
  int success = 0;
  DocumentSnapshot classReference;
  TextEditingController _editingController = TextEditingController();
  List<QueryDocumentSnapshot> studentsReference = [];
  Map<String, List<String>> months = {};
  List<QueryDocumentSnapshot> dynamicStudentsReference = [];
  Map<String, List<String>> attendenceMap = {};

  _getClassData() async {
    setState(() {
      loading = true;
    });
    classes.doc(widget.level).get().then((querySnapshot) async {
      setState(() {
        loading = false;
        classReference = querySnapshot;
      });
      querySnapshot.data().forEach((key, val) {
        if (key != "courses" &&
            key != "gender" &&
            key != "name" &&
            key != "current_month") {
          try {
            months[key] = List.from(val).map((at) => at.toString()).toList();
            // if (val.runtimeType.toString() == "List<dynamic>") {
            //   months[key] = List.from(val).map((at) => at.toString()).toList();
            //}
          } catch (e) {}
        }
      });
      await _getStudents();
    }).catchError((error) {
      print("class Ref error: $error");
      //_retryDialog();
      setState(() {
        loading = false;
      });
    });
  }

  _getStudents() async {
    setState(() {
      loading = true;
    });
    students
        .where('class', isEqualTo: widget.level)
        .get()
        .then((querySnapshot) {
      setState(() {
        loading = false;
        studentsReference = querySnapshot.docs;
        dynamicStudentsReference = querySnapshot.docs;
      });
    }).catchError((error) {
      setState(() {
        loading = false;
      });
    });
  }

  Future<void> _exportDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ወደ Excel"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                loading
                    ? Center(child: CircularProgressIndicator())
                    : Text("ወደ Excel የሚወጣውን ይምረጡ"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "አቴንዳንስ ሳይጨመር",
                style: TextStyle(
                    color: primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                var result = await getCsv(false);
                if (result != null) {
                  if (result) {
                    setState(() {
                      success = 1;
                    });
                  } else {
                    success = 2;
                  }
                } else {
                  success = 2;
                }
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                "ከአቴንዳንስ ጋር",
                style: TextStyle(
                    color: dark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                var result = await getCsv(true);
                if (result != null) {
                  if (result) {
                    setState(() {
                      success = 1;
                    });
                  } else {
                    success = 2;
                  }
                } else {
                  success = 2;
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _successDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("መረጃው ወደ Excel ተግልብጧል"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                loading
                    ? Center(child: CircularProgressIndicator())
                    : Text("መረጃው 'Downloads' ፎልደር ላይ ተቀምጧል"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "ተመለስ",
                style: TextStyle(
                    color: dark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _errorDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("መረጃው ወደ Excel አልተገለበጥም"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                loading
                    ? Center(child: CircularProgressIndicator())
                    : Text("መረጃውን መገልበጥ አልተቻለም"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "ተመለስ",
                style: TextStyle(
                    color: dark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void filterSearchResults(String query) {
    List<QueryDocumentSnapshot> dummySearchList = [];

    dummySearchList.addAll(studentsReference);
    if (query.isNotEmpty) {
      List<QueryDocumentSnapshot> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item
            .data()['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        dynamicStudentsReference.clear();
        dynamicStudentsReference.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        dynamicStudentsReference.clear();
        dynamicStudentsReference.addAll(studentsReference);
      });
    }
  }

  String filePath;

  Future<void> writeFile(String data) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Directory tempDir = await DownloadsPathProvider.downloadsDirectory;
    String tempPath = tempDir.path;
    var filePath = tempPath + '/${widget.level}.csv';
    File(filePath).writeAsStringSync(data);
  }

  Future<bool> getCsv(bool attendence) async {
    setState(() {
      loading = true;
    });
    try {
      if (studentsReference.length > 0) {
        List<List<String>> rows = List<List<String>>();
        List<String> headers = [
          'name',
          'c_name',
          'age',
          'dob',
          'class',
          'school',
          'grade',
          'm_name',
          'm_phone',
          'f_phone'
        ];
        List<String> courses = List.from(classReference.data()['courses'])
            .map((c) => c.toString())
            .toList();

        headers.addAll(courses);
        List<String> attendenceHeaders = [];
        if (attendence) {
          studentsReference[0].data().keys.toList().forEach((attendence) {
            if (attendence.contains('202')) {
              attendenceHeaders.add(attendence);
            }
          });
          if (attendenceHeaders.length > 0) {
            attendenceHeaders.sort((b, a) => a.compareTo(b));
            headers.addAll(attendenceHeaders);
          }
        }

        rows.add(headers);
        studentsReference.forEach((stuRef) {
          List<String> row = [
            stuRef.data()['name'],
            stuRef.data()['c_name'],
            stuRef.data()['age'].toString(),
            stuRef.data()['dob'].toString(),
            stuRef.data()['class'],
            stuRef.data()['school'],
            stuRef.data()['grade'].toString(),
            stuRef.data()['m_name'],
            stuRef.data()['m_phone'] != 0
                ? stuRef.data()['m_phone'].toString()
                : '-',
            stuRef.data()['f_phone'] != 0
                ? stuRef.data()['f_phone'].toString()
                : '-',
          ];
          courses.forEach((course) {
            row.add(stuRef.data()[course].toString());
          });
          if (attendence) {
            attendenceHeaders.forEach((attendence) {
              row.add(stuRef.data()[attendence].toString());
            });
          }
          rows.add(row);
        });
        String csv = const ListToCsvConverter().convert(rows);
        await writeFile(csv);
        setState(() {
          loading = false;
        });
        return true;
      }
    } catch (e) {
      print("EXCEL ERORR $e");

      setState(() {
        loading = false;
      });
      return false;
    }
  }

  @override
  void initState() {
    _getClassData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: studentsReference != []
              ? Text("${dynamicStudentsReference.length} ተማሪዎች")
              : Text(widget.level),
          backgroundColor: primary,
          actions: [
            InkWell(
                onTap: () {
                  _getClassData();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.refresh),
                )),
            InkWell(
                onTap: () async {
                  await _exportDialog();
                  if (success != 0) {
                    if (success == 1) {
                      _successDialog();
                    } else {
                      _errorDialog();
                    }
                  }
                  // _getClassData();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.table_view),
                )),
          ],
        ),
        //drawer: MenuDrawer(),
        body: SafeArea(
            child: Padding(
          padding: EdgeInsets.all(8.0),
          child: !loading
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0, left: 8.0, right: 8.0),
                      child: TextField(
                        onChanged: (value) {
                          filterSearchResults(value);
                        },
                        controller: _editingController,
                        decoration: InputDecoration(
                          hintText: "ፈልግ",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: dynamicStudentsReference.length,
                        itemBuilder: (BuildContext context, int index) {
                          return StudentItem(
                              courseList: classReference.data()['courses'],
                              currentMonthAttendence: classReference.data()[
                                  classReference.data()['current_month']],
                              ref: dynamicStudentsReference[index],
                              attendenceMonths: months);
                        },
                      ),
                    ),
                  ],
                )
              : Container(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(child: Loading(context))),
        )));
  }
}
