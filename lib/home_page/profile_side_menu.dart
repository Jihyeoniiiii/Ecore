import 'package:ecore/models/firebase_auth_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileSideMenu extends StatelessWidget {

  final double menuWidth;

  const ProfileSideMenu(this.menuWidth, {super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: menuWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title:Text(
              'Setting',
              style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.black87,
              ),
              title: Text('Sign out'),
              onTap: () {
                Provider.of<FirebaseAuthState>(context, listen: false)
                    .signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
