import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("St. Michael"),
              accountEmail: Text("CMS"),
              currentAccountPicture: GestureDetector(
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/classess_page');
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Classes",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
