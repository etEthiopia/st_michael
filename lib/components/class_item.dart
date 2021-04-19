import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:st_michael/theme/themecolor.dart';

class ClassItem extends StatelessWidget {
  ClassItem({Key key, this.ref}) : super(key: key);
  final QueryDocumentSnapshot ref;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: accent,
          offset: const Offset(1.5, 1.5),
          blurRadius: 2.0,
          spreadRadius: 1.0,
        ),
      ], color: cardcolor, borderRadius: BorderRadius.circular(5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              ref.data()['name'],
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            ref.data()['gender'] == 1 ? "ወ" : "ሴ",
            style: TextStyle(
                fontSize: 18, color: dark, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
