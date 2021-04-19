import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:st_michael/components/loading.dart';
import 'package:st_michael/main.dart';
import 'package:st_michael/students_of_class.dart';
import 'package:st_michael/theme/themecolor.dart';

class StudentPage extends StatefulWidget {
  final QueryDocumentSnapshot studentFile;
  final List<String> courses;
  final List<dynamic> currentMonthAttendence;
  final Map<String, List<String>> attendenceMonths;
  const StudentPage(
      {Key key,
      this.studentFile,
      this.courses,
      this.currentMonthAttendence,
      this.attendenceMonths})
      : super(key: key);
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  bool loading = false;
  int success = 0;
  bool change = false;
  bool attendence = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _cnameController = TextEditingController();
  TextEditingController _mphoneController = TextEditingController();
  TextEditingController _fphoneController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _mnameController = TextEditingController();
  TextEditingController _schoolController = TextEditingController();
  TextEditingController _gradeController = TextEditingController();
  TextEditingController _dobController = TextEditingController();

  Map<String, TextEditingController> textEditingControllers = {};
  var courseFields = <TextField>[];
  Map<String, int> attendenceValues = {};

  Future<void> _saveDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ዳታ መቀየር"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                loading
                    ? Center(child: CircularProgressIndicator())
                    : Text(
                        "የ ${widget.studentFile.data()['name']}ን ዳታ ሊቀይሩ ነው ፤ እርግጠኛ ነዎት?"),
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
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                "አዎ",
                style: TextStyle(
                    color: dark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                try {
                  Map<String, dynamic> updates = {
                    'name': _nameController.text,
                    'c_name': _cnameController.text,
                    'age': int.parse(_ageController.text),
                    'm_phone': int.parse(_mphoneController.text),
                    'f_phone': int.parse(_fphoneController.text),
                    'm_name': _mnameController.text,
                    'school': _schoolController.text,
                    'grade': int.parse(_gradeController.text),
                    'dob': _dobController.text
                  };
                  widget.courses.forEach((course) {
                    updates[course] =
                        int.parse(textEditingControllers[course].text);
                  });
                  students.doc(widget.studentFile.id).update(updates);
                  setState(() {
                    loading = false;
                    change = true;
                    success = 1;
                  });
                } catch (e) {
                  print(e);
                  setState(() {
                    loading = false;
                    success = 2;
                  });
                }
                Navigator.pop(context);
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
          title: Text("የተማሪው ዳታ ተመዝግቧል"),
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
          title: Text("የተማሪው ዳታ አልተመዘገበም"),
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
    widget.attendenceMonths.forEach((month, days) {
      int atnum = 0;
      int latenum = 0;
      print(days);
      print(month);
      days.forEach((day) {
        setState(() {
          attendence = true;
        });
        print("$day: " + widget.studentFile.data()[day].toString());
        if (widget.studentFile.data()[day] != 'false' &&
            widget.studentFile.data()[day] != null) {
          atnum++;
        }
        if (widget.studentFile.data()[day] == 'late') {
          latenum += 1;
        }
      });
      atnum -= latenum ~/ 3;
      attendenceValues[month] = atnum;
      print("$month: " + attendenceValues[month].toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = widget.studentFile.data()['name'];
    _cnameController.text = widget.studentFile.data()['c_name'];
    _mphoneController.text = widget.studentFile.data()['m_phone'].toString();
    _fphoneController.text = widget.studentFile.data()['f_phone'].toString();
    _ageController.text = widget.studentFile.data()['age'].toString();
    _mnameController.text = widget.studentFile.data()['m_name'];
    _schoolController.text = widget.studentFile.data()['school'];
    _gradeController.text = widget.studentFile.data()['grade'].toString();
    _dobController.text = widget.studentFile.data()['dob'].toString();
    widget.courses.forEach((course) {
      var textEditingController = new TextEditingController(
          text: widget.studentFile.data()[course].toString());
      textEditingControllers.putIfAbsent(course, () => textEditingController);
      courseFields.add(TextField(
          controller: textEditingController,
          decoration: InputDecoration(labelText: course, hintText: course),
          inputFormatters: [
            LengthLimitingTextInputFormatter(3),
          ]));
    });
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primary,
          title: Text(widget.studentFile.data()['name']),
        ),
        body: SafeArea(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
              child: !loading
                  ? Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Column(children: [
                                  Container(
                                      child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              labelText: "ስም", hintText: "ስም"),
                                          keyboardType: TextInputType.name,
                                          controller: _nameController,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "The Name cannot be empty";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ))
                                ]),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(children: [
                                  Container(
                                      child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              labelText: "የትውልድ ጊዜ",
                                              hintText: "የትውልድ ጊዜ"),
                                          keyboardType: TextInputType.name,
                                          controller: _dobController,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "The DoB cannot be empty";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              labelText: "የክርስትና ስም",
                                              hintText: "የክርስትና ስም"),
                                          keyboardType: TextInputType.name,
                                          controller: _cnameController,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "The C-Name cannot be empty";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ))
                                ]),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                                decoration: InputDecoration(
                                                    labelText: "እድሜ",
                                                    hintText: "እድሜ"),
                                                keyboardType:
                                                    TextInputType.name,
                                                controller: _ageController,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return "The Age cannot be empty";
                                                  }
                                                  return null;
                                                },
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      2),
                                                ]),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "የእናት ስም",
                                                  hintText: "የእናት ስም"),
                                              keyboardType: TextInputType.name,
                                              controller: _mnameController,
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return "The M-Name cannot be empty";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                                decoration: InputDecoration(
                                                    labelText: "የእናት ስልክ",
                                                    hintText: "የእናት ስልክ"),
                                                keyboardType:
                                                    TextInputType.name,
                                                controller: _mphoneController,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return "The M-Phone cannot be empty";
                                                  }
                                                  return null;
                                                },
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      9),
                                                ]),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                                decoration: InputDecoration(
                                                    labelText: "የአባት ስልክ",
                                                    hintText: "የአባት ስልክ"),
                                                keyboardType:
                                                    TextInputType.name,
                                                controller: _fphoneController,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return "The F-Phone cannot be empty";
                                                  }
                                                  return null;
                                                },
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      9),
                                                ]),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "የትምህርት ቤት ስም",
                                                  hintText: "የትምህርት ቤት ስም"),
                                              keyboardType: TextInputType.name,
                                              controller: _schoolController,
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return "The School cannot be empty";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                                decoration: InputDecoration(
                                                    labelText: "የትምህርት ደረጃ",
                                                    hintText: "የትምህርት ደረጃ"),
                                                keyboardType:
                                                    TextInputType.name,
                                                controller: _gradeController,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return "The Grade cannot be empty";
                                                  }
                                                  return null;
                                                },
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      2),
                                                ]),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                ...courseFields.map((courseField) {
                                  return Column(
                                    children: [
                                      courseField,
                                      SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  );
                                }).toList(),
                                SizedBox(
                                  height: 25,
                                ),
                                attendence
                                    ? Text(
                                        "አቴንዳንስ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      )
                                    : SizedBox(height: 0),
                                SizedBox(
                                  height: 5,
                                ),
                                ...widget.attendenceMonths.keys.map((month) {
                                  return widget.attendenceMonths[month].length >
                                          0
                                      ? ExpansionTile(
                                          title: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  month,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              Text(
                                                attendenceValues[month]
                                                        .toString() +
                                                    "/" +
                                                    widget
                                                        .attendenceMonths[month]
                                                        .length
                                                        .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: dark,
                                                    fontSize: 17),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                          children: [
                                            ...widget.attendenceMonths[month]
                                                .map((cmonth) {
                                              return ListTile(
                                                  title: Text(
                                                      cmonth +
                                                          " :   " +
                                                          widget.studentFile
                                                              .data()[cmonth]
                                                              .toString(),
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                      )));
                                            }).toList(),
                                          ],
                                        )
                                      : SizedBox(
                                          height: 0,
                                        );
                                  // Text(
                                  //     widget.attendenceMonths.entries
                                  //         .toList()
                                  //         .toString(),
                                  //     style: TextStyle(
                                  //         fontWeight: FontWeight.bold,
                                  //         fontSize: 18),
                                  //   );
                                }).toList()
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RaisedButton(
                                  color: primary,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "ተመለስ",
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
                      ],
                    )
                  : Container(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: Loading(context)))),
        ));
  }
}
