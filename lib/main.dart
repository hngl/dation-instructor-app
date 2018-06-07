import 'package:dation_app/agenda_page.dart';
import 'package:dation_app/course_instances_page.dart';
import 'package:dation_app/dation_ws_client.dart';
import 'package:dation_app/login_page.dart';
import 'package:dation_app/students_page.dart';
import 'package:flutter/material.dart';

final String _wsHost = 'https://dashboard.dation.nl';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dation',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: Colors.purple[800],
        accentColor: Colors.lightBlue[300],
        splashColor: Colors.redAccent,
      ),
      home: LoginPage(), //HomePage());
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
    MenuItem('Leerlingen', icon: Icons.people),
    MenuItem('Cursussen', icon: Icons.bubble_chart),
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
          ..setTenant(Tenant(873, 'dation'))
          ..setUser(User(1, 'beheerder'));

        return AgendaPage(client);
      case 1:
        return StudentsListPage();
      case 2:
        return CourseInstancesPage();

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
