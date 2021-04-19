import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:st_michael/student_page.dart';
import 'package:st_michael/theme/themecolor.dart';

class StudentItem extends StatelessWidget {
  StudentItem(
      {Key key,
      this.ref,
      this.currentMonthAttendence,
      this.courseList,
      this.attendenceMonths})
      : super(key: key);
  final QueryDocumentSnapshot ref;
  final List<dynamic> currentMonthAttendence;
  final Map<String, List<String>> attendenceMonths;
  final List<dynamic> courseList;
  int attendenceNum = 0;
  int latenum = 0;
  Map<String, int> attendenceValues = {};

  @override
  Widget build(BuildContext context) {
    try {
      currentMonthAttendence.forEach((date) {
        if (ref.data()[date] != 'false' && ref.data()[date] != null) {
          attendenceNum += 1;
        }
        if (ref.data()[date] == 'late') {
          latenum += 1;
        }
      });
      attendenceNum -= latenum ~/ 3;
    } catch (e) {}

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1, vertical: 5),
      color: cardcolor,
      child: ExpansionTile(
        title: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.more,
                size: 17,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => StudentPage(
                            studentFile: ref,
                            currentMonthAttendence: currentMonthAttendence,
                            attendenceMonths: attendenceMonths,
                            courses: List.from(courseList)
                                .map((c) => c.toString())
                                .toList())));
              },
            ),
            Expanded(
              child: Text(
                ref.data()['name'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            SizedBox(
              width: 3,
            ),
            currentMonthAttendence != null
                ? Text(
                    attendenceNum.toString() +
                        "/" +
                        currentMonthAttendence.length.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: dark, fontSize: 17),
                  )
                : Text(
                    "0/0",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: dark, fontSize: 17),
                  ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        children: [
          ...courseList.map((course) {
            return ListTile(
                title: Text(course + " :   " + ref.data()[course].toString(),
                    style: TextStyle(
                      fontSize: 17,
                    )));
          }).toList(),
        ],
      ),
    );
  }
}
