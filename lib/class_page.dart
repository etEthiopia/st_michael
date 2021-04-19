import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:st_michael/attendence_page.dart';
import 'package:st_michael/components/loading.dart';
import 'package:st_michael/components/menu_drawer.dart';
import 'package:st_michael/grading_page.dart';
import 'package:st_michael/main.dart';
import 'package:st_michael/new_student_page.dart';
import 'package:st_michael/students_of_class.dart';
import 'package:st_michael/theme/themecolor.dart';

// ignore: must_be_immutable
class ClassPage extends StatefulWidget {
  ClassPage({Key key, this.ref}) : super(key: key);
  DocumentSnapshot ref;
  @override
  _ClassPageState createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  String className = '';
  String currentMonth = '';
  List<dynamic> currentMonthAttendence = [];
  List<String> dates = [];
  List<String> courses = [];
  bool loading = false;
  int success = 0;
  bool coursefield = false;
  bool addmonth = false;
  final TextEditingController _coursename = TextEditingController();
  final TextEditingController _addmonthname = TextEditingController();

  _getClassData() async {
    setState(() {
      className = widget.ref.data()['name'];
      currentMonth = widget.ref.data()['current_month'];
      courses = List.from(widget.ref.data()['courses']);
      loading = true;
    });
    List<String> tempdates = [];
    widget.ref.data().forEach((key, val) {
      if (key != "courses") {
        if (val.runtimeType.toString() == "List<dynamic>") {
          List<String> mdates =
              List.from(val).map((at) => at.toString()).toList();
          tempdates.addAll(mdates);
        }
      }
    });
    setState(() {
      dates = tempdates;
    });
    tempdates = [];
    setState(() {
      currentMonthAttendence = widget.ref.data()[currentMonth];
      loading = false;
    });
  }

  _updateClassData() {
    setState(() {
      loading = true;
    });
    try {
      classes.doc(widget.ref.id).get().then((ds) {
        widget.ref = ds;
        setState(() {
          currentMonth = widget.ref.data()['current_month'];
          courses = List.from(widget.ref.data()['courses']);
        });
        List<String> tempdates = [];
        widget.ref.data().forEach((key, val) {
          if (key != "courses") {
            if (val.runtimeType.toString() == "List<dynamic>") {
              List<String> mdates =
                  List.from(val).map((at) => at.toString()).toList();
              tempdates.addAll(mdates);
            }
          }
        });
        setState(() {
          dates = tempdates;
          loading = false;
        });
        tempdates = [];
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _successDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("በትክክል ተመዝግቧል"),
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
          title: Text("በትክክል አልተመዘገበም"),
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

  Future<void> _addCourse() async {
    setState(() {
      loading = true;
    });
    List<DocumentReference> studs = [];
    students.where('class', isEqualTo: className).get().then((snapshot) async {
      for (var ss in snapshot.docs) {
        studs.add(ss.reference);
      }
      firestore.runTransaction((transaction) async {
        transaction.update(widget.ref.reference, {
          "courses": FieldValue.arrayUnion([_coursename.text])
        });
        for (var stu in studs) {
          transaction.update(stu, {_coursename.text: 0});
        }

        setState(() {
          loading = false;
          _coursename.text = "";
          coursefield = false;
        });
      });
    });
  }

  Future<void> _addmonth() async {
    setState(() {
      loading = true;
    });
    try {
      var batch;
      batch = firestore.batch();
      List<String> dummy = [];
      batch.set(widget.ref.reference, {'current_month': _addmonthname.text},
          SetOptions(merge: true));
      batch.set(widget.ref.reference, {_addmonthname.text: dummy},
          SetOptions(merge: true));

      batch.commit();
      batch = firestore.batch();
      print("about to update");
      await _updateClassData();
      print("update done");
      setState(() {
        loading = false;
        _addmonthname.text = "";
        addmonth = false;
      });
    } catch (e) {
      loading = false;
      _addmonthname.text = "";
      addmonth = false;
      print("Updating Error: $e");
    }
  }

  @override
  void initState() {
    _getClassData();
    super.initState();
  }

  Future<void> _showAddCourseDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_coursename.text),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                loading
                    ? Center(child: CircularProgressIndicator())
                    : Text("ይህንን ኮርስ ለመጨመር ማረጋገጫ ይስጡ"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "ተመለስ",
                style: TextStyle(
                    color: primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  _coursename.text = "";
                  addmonth = false;
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                "አረጋግጥ",
                style: TextStyle(
                    color: dark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await _addCourse();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddMonthDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_addmonthname.text),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                loading
                    ? Center(child: CircularProgressIndicator())
                    : Text("ይህንን ወር ለመጨመር ማረጋገጫ ይስጡ"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "ተመለስ",
                style: TextStyle(
                    color: primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  _addmonthname.text = "";
                  coursefield = false;
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                "አረጋግጥ",
                style: TextStyle(
                    color: dark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await _addmonth();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(className),
        actions: [
          InkWell(
              onTap: () {
                _updateClassData();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.refresh),
              ))
        ],
      ),
      //drawer: MenuDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: !loading
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "ያለበት ወር :  ",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            currentMonth,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      currentMonth != ""
                          ? RaisedButton(
                              color: primary,
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            AttendencePage(
                                                currentMonth: currentMonth,
                                                level: className)));
                              },
                              child: Text(
                                "አቴንዳንስ ያዝ",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              ))
                          : SizedBox(
                              height: 0,
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      RaisedButton(
                          color: primary,
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        StudentsOfClass(level: className)));
                          },
                          child: Text(
                            "የተማሪዎች ዝርዝር",
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      RaisedButton(
                          color: dark,
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        NewStudentPage(
                                            courses: courses,
                                            dates: dates,
                                            level: className)));
                          },
                          child: Text(
                            "አዲስ ተማሪ",
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(hintText: "የወር ስም"),
                                keyboardType: TextInputType.name,
                                controller: _addmonthname,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "The Month Name cannot be empty";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              color: dark,
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _addmonthname.text = "";
                                  addmonth = false;
                                });
                              },
                            )
                          ],
                        ),
                        visible: addmonth,
                      ),
                      addmonth
                          ? SizedBox(
                              height: 10,
                            )
                          : SizedBox(
                              height: 0,
                            ),
                      RaisedButton(
                          color: dark,
                          onPressed: () {
                            if (addmonth) {
                              _showAddMonthDialog();
                              if (success != 0) {
                                if (success == 1) {
                                  _successDialog();
                                } else {
                                  _errorDialog();
                                }
                              }
                            } else {
                              setState(() {
                                addmonth = true;
                              });
                            }
                          },
                          child: Text(
                            addmonth ? "አዲስ ወር መዝግብ" : "አዲስ ወር",
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration:
                                    InputDecoration(hintText: "የኮርስ ስም"),
                                keyboardType: TextInputType.name,
                                controller: _coursename,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "The Course Name cannot be empty";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              color: dark,
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _coursename.text = "";
                                  coursefield = false;
                                });
                              },
                            )
                          ],
                        ),
                        visible: coursefield,
                      ),
                      coursefield
                          ? SizedBox(
                              height: 10,
                            )
                          : SizedBox(
                              height: 0,
                            ),
                      RaisedButton(
                          color: dark,
                          onPressed: () {
                            if (coursefield) {
                              _showAddCourseDialog();
                              if (success != 0) {
                                if (success == 1) {
                                  _successDialog();
                                } else {
                                  _errorDialog();
                                }
                              }
                            } else {
                              setState(() {
                                coursefield = true;
                              });
                            }
                          },
                          child: Text(
                            coursefield ? "ኮርስ መዝግብ" : "አዲስ ኮርስ",
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "ኮርሶች",
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(
                          child: Column(
                        children: <Widget>[
                          ...courses.map((course) {
                            return Container(
                              color: Colors.grey[100],
                              height: 50,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        course,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: dark,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    color: accent,
                                    icon: Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 25,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  GradingPage(
                                                      subject: course,
                                                      level: className)));
                                    },
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      )

                          // ListView.builder(
                          //   itemCount: courses.length,
                          //   itemBuilder: (BuildContext context, int index) {
                          //     return Container(
                          //       color: Colors.grey[100],
                          //       height: 50,
                          //       margin: EdgeInsets.symmetric(
                          //           horizontal: 5, vertical: 5),
                          //       padding: EdgeInsets.symmetric(
                          //           horizontal: 5, vertical: 5),
                          //       child: Row(
                          //         children: [
                          //           Expanded(
                          //             child: Padding(
                          //               padding: const EdgeInsets.symmetric(
                          //                   horizontal: 8.0),
                          //               child: Text(
                          //                 courses[index],
                          //                 maxLines: 1,
                          //                 overflow: TextOverflow.ellipsis,
                          //                 style: TextStyle(
                          //                     fontSize: 17,
                          //                     color: dark,
                          //                     fontWeight: FontWeight.bold),
                          //               ),
                          //             ),
                          //           ),
                          //           IconButton(
                          //             color: accent,
                          //             icon: Icon(
                          //               Icons.arrow_forward_ios_outlined,
                          //               size: 25,
                          //             ),
                          //             onPressed: () {
                          //               Navigator.push(
                          //                   context,
                          //                   MaterialPageRoute(
                          //                       builder:
                          //                           (BuildContext context) =>
                          //                               GradingPage(
                          //                                   subject:
                          //                                       courses[index],
                          //                                   level: className)));
                          //             },
                          //           )
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // ),
                          ),
                    ],
                  )
                : Container(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: Loading(context))),
          ),
        ),
      ),
    );
  }
}
