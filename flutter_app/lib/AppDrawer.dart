import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'AppState.dart';
import 'LoginPage.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage;
  AppState appState;
  Drawer? drawer;
  AppDrawer(this.currentPage, this.appState);

  @override
  Widget build(BuildContext context) {
    // var currentDrawer = Provider.of<DrawerStateInfo>(context).getCurrentDrawer;
    drawer = Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      key: PageStorageKey<String>('drawer_key'),
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('K-Corp'),
          ),
          ListTile(
            title: (appState.isLoggedIn()) ? Text('Logout') : Text('Login'),
            onTap: () {
              if (!appState.isLoggedIn())
                _showLoginPage(context);
              else {
                appState.logout();
                Fluttertoast.showToast(
                    msg: "You are now logged out.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                Navigator.pop(context); // Pop the drawer closed
              }
            },
          ),
        ],
      ),
    );
    return drawer as Widget;
  }

  /// Show the orderDetailPage for the given [order]
  Future<void> _showLoginPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
