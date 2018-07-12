import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:instructorapp/agenda_page.dart';
import 'package:instructorapp/dation_ws_client.dart';
import 'package:instructorapp/login_page.dart';
import 'package:instructorapp/dation_models.dart';

final String _wsHost = 'https://dashboard.dation.nl';

const _dationPurple = Color(0xFF561D9F);
const _dationRed = Color(0xFFFF5D51);
const _dationBlue = Color(0xFF66BBD4);

void main() {
  runApp(MyApp());
}

/// This widget is the root of the application.
class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = new FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = new FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    analytics.logAppOpen();

    return MaterialApp(
      title: 'Dation',
      navigatorObservers: <NavigatorObserver>[observer],
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: _dationPurple,
        splashColor: _dationRed,
        buttonColor: _dationBlue,
      ),
      home: LoginPage(
        analytics: analytics,
        observer: observer,
      ), //HomePage());
    );
  }
}

class MenuItem {
  String title;
  IconData icon;

  MenuItem(this.title, {this.icon});
}

// Main layout and navigation
class HomePage extends StatefulWidget {
  final drawerItems = [
    MenuItem('Agenda', icon: Icons.calendar_today),
  ];

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        var client = DationWsClient(_wsHost)
          ..tenant = Tenant(873, 'dation')
          ..user = User(1, 'beheerder');

        return AgendaPage(client);

      default:
        return Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var item = widget.drawerItems[i];
      drawerOptions.add(ListTile(
        leading: item.icon != null ? Icon(item.icon) : Text(''),
        title: Text(item.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        // here we display the title corresponding to the fragment
        // you can instead choose to have a static title
        title: Text(widget.drawerItems[_selectedDrawerIndex].title),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
                accountName: Text("Beheerder"), accountEmail: null),
            Column(children: drawerOptions),
          ],
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }
}
