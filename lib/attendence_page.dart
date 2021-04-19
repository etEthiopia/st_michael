import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:st_michael/components/loading.dart';
import 'package:st_michael/components/menu_drawer.dart';
import 'package:st_michael/main.dart';
import 'package:st_michael/theme/themecolor.dart';

class AttendencePage extends StatefulWidget {
  AttendencePage({Key key, this.currentMonth, this.level}) : super(key: key);
  final String currentMonth;

  final String level;
  @override
  _AttendencePage createState() => _AttendencePage();
}

class _AttendencePage extends State<AttendencePage> {
  DateTime selectedDate = DateTime.now();
  int attendedDates;
  DateTime lastAttendence;
  bool loading = false;
  int success = 0;
  DocumentSnapshot classReference;
  List<QueryDocumentSnapshot> studentsReference = [];
  List<int> attendenceNumbs = [];
  Map<String, bool> selectedorNot = {};
  Map<String, bool> lateorNot = {};

  Future<void> _selectDate(BuildContext context) async {
    //firstDate: lastAttendence != null ? lastAttendence : DateTime(2021),
    //lastDate: DateTime.now()
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2018),
        lastDate: DateTime(2022));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  _getStudentData() async {
    setState(() {
      loading = true;
      attendenceNumbs = [];
      selectedorNot = {};
    });
    try {
      QuerySnapshot qs =
          await students.where('class', isEqualTo: widget.level).get();

      setState(() {
        loading = false;
        studentsReference = qs.docs;
      });
      print(qs.docs.length);
      qs.docs.forEach((ref) {
        // print(ref.id);
        // print(ref.data()['name']);
        selectedorNot[ref.id] = true;
        lateorNot[ref.id] = false;
        //print("class reference: $classReference");
        int att = 0;
        int latenum = 0;
        classReference.data()[widget.currentMonth].forEach((date) {
          if (ref.data()[date] != 'false' && ref.data()[date] != null) {
            att += 1;
          }
          if (ref.data()[date] == 'late') {
            latenum += 1;
          }
        });
        att -= latenum ~/ 3;
        attendenceNumbs.add(att);
      });
      setState(() {
        loading = false;
      });
    } catch (e) {
      print("errrorrr : $e");
      _retryDialog();
      setState(() {
        loading = false;
      });
    }
    // .catchError((error) {
    //   _retryDialog();
    //   setState(() {
    //     loading = false;
    //   });
    // });
  }

  _getClassData() async {
    setState(() {
      loading = true;
    });
    classes.doc(widget.level).get().then((querySnapshot) async {
      setState(() {
        loading = false;
        classReference = querySnapshot;
      });
      await _getStudentData();
      try {
        List<String> fulldate =
            classReference.data()[widget.currentMonth].last.split('-');
        setState(() {
          lastAttendence = DateTime(int.parse(fulldate[0]),
              int.parse(fulldate[1]), int.parse(fulldate[2]));
        });
      } catch (e) {
        print("date error");
        setState(() {
          loading = false;
        });
      }
    }).catchError((error) {
      print("class Ref error: $error");
      _retryDialog();
      setState(() {
        loading = false;
      });
    });
  }

  _updateAttendence() {
    setState(() {
      loading = true;
    });
    try {
      var batch;
      batch = firestore.batch();

      batch.set(
          classReference.reference,
          {
            widget.currentMonth: FieldValue.arrayUnion(
                [selectedDate.toLocal().toString().split(' ')[0]])
          },
          SetOptions(merge: true));

      studentsReference.forEach((student) {
        batch.set(
            student.reference,
            {
              selectedDate.toLocal().toString().split(' ')[0]:
                  lateorNot[student.id]
                      ? "late"
                      : selectedorNot[student.id].toString()
            },
            SetOptions(merge: true));
      });

      batch.commit();
      batch = firestore.batch();
      setState(() {
        loading = false;
        success = 1;
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        loading = false;
        success = 2;
      });
      print("Updating Error: $e");
    }
  }

  Future<void> _successDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("አቴንዳንስ ተመዝግቧል"),
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
          title: Text("አቴንዳንስ አልተመዘገበም"),
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

  @override
  void initState() {
    _getClassData();
    super.initState();
  }

  Future<void> _cancelDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ስርዝ"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                loading ? CircularProgressIndicator() : Text("ለመሰረዝ ማረጋገጫ ይስጡ"),
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
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                "አረጋግጥ",
                style: TextStyle(
                    color: dark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                selectedorNot.forEach((id, val) {
                  setState(() {
                    selectedorNot[id] = true;
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("መዝግብ"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                loading
                    ? Center(child: CircularProgressIndicator())
                    : Text("ለመመዝገብ ማረጋገጫ ይስጡ"),
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
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                "አረጋግጥ",
                style: TextStyle(
                    color: dark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _updateAttendence();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _retryDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ይቅርታ"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                loading
                    ? Center(child: CircularProgressIndicator())
                    : Text("ዳታ በስርዐት አልተቀበለም ፡ እባክዎ ድጋሚ ይሞክሩ"),
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                "ድጋሚ ይሞክሩ",
                style: TextStyle(
                    color: dark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _getClassData();
                _getStudentData();
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
        appBar: AppBar(
          backgroundColor: primary,
          title: Text(selectedDate.toLocal().toString().split(' ')[0]),
          actions: [
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                child: Icon(
                  Icons.date_range,
                  color: Colors.white,
                ),
                padding: EdgeInsets.only(right: 10),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            InkWell(
                onTap: () {
                  _getClassData();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.refresh),
                )),
          ],
        ),
        //drawer: MenuDrawer(),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: !loading
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: Container(
                        child: ListView.builder(
                          itemCount: studentsReference.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              color: Colors.grey[200],
                              height: 50,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            studentsReference[index]
                                                .data()['name'],
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          attendenceNumbs.length > index
                                              ? Text(
                                                  attendenceNumbs[index]
                                                          .toString() +
                                                      "/" +
                                                      classReference
                                                          .data()[widget
                                                              .currentMonth]
                                                          .length
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: dark),
                                                )
                                              : SizedBox(
                                                  height: 0,
                                                ),
                                        ],
                                      ),
                                    ),
                                    lateorNot.length > index
                                        ? Expanded(
                                            child: InkWell(
                                            child: Icon(
                                              Icons.lock_clock,
                                              color: lateorNot[
                                                      studentsReference[index]
                                                          .id]
                                                  ? primary
                                                  : Colors.grey,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                lateorNot[
                                                    studentsReference[index]
                                                        .id] = !lateorNot[
                                                    studentsReference[index]
                                                        .id];
                                                selectedorNot[
                                                    studentsReference[index]
                                                        .id] = !selectedorNot[
                                                    studentsReference[index]
                                                        .id];
                                              });
                                            },
                                          ))
                                        : SizedBox(
                                            height: 0,
                                          ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    lateorNot[studentsReference[index].id] ==
                                            false
                                        ? selectedorNot.length > index
                                            ? Expanded(
                                                child: Checkbox(
                                                  activeColor: primary,
                                                  value: selectedorNot[
                                                      studentsReference[index]
                                                          .id],
                                                  onChanged: (current) {
                                                    setState(() {
                                                      selectedorNot[
                                                          studentsReference[
                                                                  index]
                                                              .id] = current;
                                                    });
                                                  },
                                                ),
                                              )
                                            : SizedBox(
                                                height: 0,
                                              )
                                        : SizedBox(
                                            height: 0,
                                          )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RaisedButton(
                              color: primary,
                              onPressed: () {
                                _cancelDialog();
                              },
                              child: Text(
                                "ሰርዝ",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              )),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: RaisedButton(
                              color: dark,
                              onPressed: () async {
                                await _saveDialog();
                                if (success != 0) {
                                  if (success == 1) {
                                    _successDialog();
                                  } else {
                                    _errorDialog();
                                  }
                                }
                              },
                              child: Text(
                                "መዝግብ",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                )
              : Container(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(child: Loading(context))),
        )));
  }
}
