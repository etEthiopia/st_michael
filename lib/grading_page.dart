import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:st_michael/components/loading.dart';
import 'package:st_michael/components/menu_drawer.dart';
import 'package:st_michael/main.dart';
import 'package:st_michael/theme/themecolor.dart';

class GradingPage extends StatefulWidget {
  GradingPage({Key key, this.subject, this.level}) : super(key: key);
  final String subject;
  final String level;
  @override
  _GradingPageState createState() => _GradingPageState();
}

class _GradingPageState extends State<GradingPage> {
  bool loading = false;
  int success = 0;
  List<QueryDocumentSnapshot> studentsReference = [];
  Map<String, DocumentReference> changedReferences = {};
  Map<String, TextEditingController> textEditingControllers = {};
  Map<String, int> originalValues = {};
  var textFields = <TextField>[];

  _getGradeData() async {
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
      });
    }).catchError((error) {
      setState(() {
        loading = false;
      });
    });
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
                try {
                  changedReferences.forEach((changedId, changed) {
                    textEditingControllers[changedId].text =
                        originalValues[changedId].toString();
                  });
                  changedReferences = {};
                } catch (e) {}
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
                _updateGrades();
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
          title: Text("ግሬድ ተመዝግቧል"),
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
          title: Text("ግሬድ አልተመዘገበም"),
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

  _updateGrades() {
    try {
      var batch;
      batch = firestore.batch();
      changedReferences.forEach((changedStuId, changedStu) {
        print(
            "TO BE CHANGED : ${widget.subject}  $changedStuId - ${textEditingControllers[changedStuId].text}");
        batch.set(
            changedStu,
            {
              widget.subject:
                  int.parse(textEditingControllers[changedStuId].text)
            },
            SetOptions(merge: true));
        batch.commit();
        setState(() {
          success = 1;
        });
        batch = firestore.batch();
        changedReferences.forEach((changedStuId, changedStu) {
          originalValues[changedStuId] =
              int.parse(textEditingControllers[changedStuId].text);
        });
        setState(() {
          changedReferences = {};
        });
      });
      setState(() {
        loading = false;
        success = 1;
      });
    } catch (e) {
      setState(() {
        loading = false;
        success = 2;
      });
      print("Updating Error: $e");
    }
  }

  @override
  void initState() {
    _getGradeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    studentsReference.forEach((qsRef) {
      var textEditingController = new TextEditingController(
          text: qsRef.data()[widget.subject].toString());
      textEditingControllers.putIfAbsent(qsRef.id, () => textEditingController);
      originalValues.putIfAbsent(qsRef.id, () => qsRef.data()[widget.subject]);
      textFields.add(TextField(
          controller: textEditingController,
          onChanged: (text) {
            print("$text --- ${originalValues[qsRef.id]}");
            if (text != originalValues[qsRef.id].toString()) {
              changedReferences.putIfAbsent(qsRef.id, () => qsRef.reference);
            } else {
              try {
                changedReferences.remove(qsRef.id);
              } catch (e) {
                print("REMOVING TEXT == ORIGINAL ERROR: $e");
              }
            }
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(3),
          ]));
    });
    return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: primary,
          title: Text(widget.subject),
          actions: [
            InkWell(
                onTap: () {
                  _getGradeData();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.refresh),
                ))
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
                      height: 10,
                    ),
                    Text(
                      widget.level,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
                              color: cardcolor,
                              height: 50,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        studentsReference[index].data()['name'],
                                        style: TextStyle(
                                            fontSize: 18, color: dark),
                                      ),
                                    ),
                                    Expanded(
                                      child: textFields[index],
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
