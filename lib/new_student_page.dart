import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:st_michael/components/loading.dart';
import 'package:st_michael/main.dart';
import 'package:st_michael/theme/themecolor.dart';

class NewStudentPage extends StatefulWidget {
  final List<String> courses;
  final List<String> dates;
  final String level;

  const NewStudentPage({Key key, this.courses, this.dates, this.level})
      : super(key: key);
  @override
  _NewStudentPageState createState() => _NewStudentPageState();
}

class _NewStudentPageState extends State<NewStudentPage> {
  bool loading = false;
  int success = 0;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _cnameController = TextEditingController();
  TextEditingController _mphoneController = TextEditingController();
  TextEditingController _mnameController = TextEditingController();
  TextEditingController _schoolController = TextEditingController();
  TextEditingController _gradeController = TextEditingController();
  TextEditingController _fphoneController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _dobController = TextEditingController();

  Future<void> _saveDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("አዲስ ተማሪ"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                loading
                    ? Center(child: CircularProgressIndicator())
                    : Text(
                        "${_nameController.text}ን ወደ ${widget.level} ለማስገባት ማረጋገጫ ይስጡ፡፡"),
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
                "አረጋግጥ",
                style: TextStyle(
                    color: dark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                try {
                  Map<String, dynamic> newStudent = {
                    'name': _nameController.text,
                    'c_name': _cnameController.text,
                    'age': int.parse(_ageController.text),
                    'm_phone': int.parse(_mphoneController.text),
                    'f_phone': int.parse(_fphoneController.text),
                    'm_name': _mnameController.text,
                    'school': _schoolController.text,
                    'grade': int.parse(_gradeController.text),
                    'class': widget.level,
                    'dob': _dobController.text,
                  };
                  widget.courses.forEach((course) {
                    newStudent[course] = 0;
                  });
                  widget.dates.forEach((date) {
                    newStudent[date] = 'false';
                  });
                  students.add(newStudent);
                  setState(() {
                    loading = false;
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
          title: Text("ተማሪው ተመዝግቧል"),
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
          title: Text("ተማሪው አልተመዘገበም"),
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primary,
          title: Text("አዲስ ተማሪ"),
        ),
        body: SafeArea(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
              child: !loading
                  ? success == 1
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "${_nameController.text}ን መዝግበዋል",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18, color: accent),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: RaisedButton(
                                        color: primary,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.arrow_back,
                                                size: 18, color: Colors.white),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              " ወደ ${widget.level} ተመለስ",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Column(
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
                                                  labelText: "ስም",
                                                  hintText: "ስም"),
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
                                                  keyboardType:
                                                      TextInputType.name,
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
                                                    controller:
                                                        _mphoneController,
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
                                                    controller:
                                                        _fphoneController,
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
                                                  keyboardType:
                                                      TextInputType.name,
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
                                                    controller:
                                                        _gradeController,
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
                                      onPressed: () {
                                        _saveDialog();
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
