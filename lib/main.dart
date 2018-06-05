import 'package:dation_app/agenda_page.dart';
import 'package:dation_app/course_instances_page.dart';
import 'package:dation_app/dation_ws_client.dart';
import 'package:dation_app/students_page.dart';
import 'package:flutter/material.dart';

final String _wsHost = 'https://dashboard.dation.nl';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Dation',
        theme: new ThemeData(
            primaryColor: Colors.purple, accentColor: Colors.blueAccent),
        home: new HomePage());
  }
}

class MenuItem {
  String title;
  IconData icon;

  MenuItem(this.title, this.icon);
}

// Main layout and navigation
class HomePage extends StatefulWidget {
  final drawerItems = [
    new MenuItem('Agenda', Icons.calendar_today),
    new MenuItem('Leerlingen', Icons.people),
    new MenuItem('Cursussen', Icons.bubble_chart)
  ];

  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        var client = new DationWsClient(_wsHost)
          ..setTenant(new Tenant(873, 'dation'))
          ..setUser(new User(1, 'beheerder'));

        return new AgendaPage(client);
      case 1:
        return new StudentsListPage();
      case 2:
        return new CourseInstancesPage();

      default:
        return new Text("Error");
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
      var d = widget.drawerItems[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }

    return new Scaffold(
      appBar: new AppBar(
        // here we display the title corresponding to the fragment
        // you can instead choose to have a static title
        title: new Text(widget.drawerItems[_selectedDrawerIndex].title),
      ),
      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                accountName: new Text("Beheerder"), accountEmail: null),
            new Column(children: drawerOptions)
          ],
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }
}
