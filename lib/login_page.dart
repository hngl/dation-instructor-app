import 'package:dation_app/main.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();

  String _username;
  String _password;

  void _submit() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
    }

    print("Submitted $_username:$_password");
    onAuthStateChanged();
  }

  void onAuthStateChanged() {
    Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (BuildContext context) => new HomePage()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        canvasColor: Theme.of(context).primaryColor,
        brightness: Brightness.dark,
        accentColor: Theme.of(context).accentColor,
        splashColor: Theme.of(context).splashColor,
        buttonColor: Theme.of(context).accentColor
      ),
      child: new Scaffold(
        body: new Center(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Image.network(
                'http://www.dation.nl/wp-content/uploads/2018/04/elephant_white-300x257.png',
              ),
              new Form(
                key: formKey,
                child: new Padding(
                  padding: EdgeInsets.all(30.0),
                  child: new Column(
                    children: <Widget>[
                      new TextFormField(
                        initialValue: 'beheerder',
                        onSaved: (val) => _username = val,
                        decoration:
                            new InputDecoration(labelText: "Gebruikersnaam"),
                      ),
                      SizedBox(height: 24.0),
                      new TextFormField(
                        initialValue: 'beheerder12',
                        obscureText: true,
                        onSaved: (val) => _password = val,
                        decoration:
                            new InputDecoration(labelText: "Wachtwoord"),
                      ),
                      SizedBox(height: 48.0),
                      new RaisedButton(
                        onPressed: _submit,
                        child: new Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 40.0,
                          ),
                          child: new Text('Aanmelden'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
