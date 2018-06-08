import 'package:dation_app/main.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  String _username;
  String _password;
  String _handle;

  void _submit() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
    }

    print("Submitted $_username@$_handle:$_password");
    onAuthStateChanged();
  }

  void onAuthStateChanged() {
    Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          canvasColor: Theme.of(context).primaryColor,
          brightness: Brightness.dark,
          accentColor: Theme.of(context).accentColor,
          splashColor: Theme.of(context).splashColor,
          buttonColor: Theme.of(context).accentColor),
      child: Scaffold(
        body: Center(
          child: new SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.network(
                  'http://www.dation.nl/wp-content/uploads/2018/04/elephant_white-300x257.png',
                ),
                Form(
                  key: formKey,
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          initialValue: 'dation',
                          onSaved: (val) => _handle = val,
                          decoration:
                          InputDecoration(labelText: "Rijschool"),
                        ),
                        SizedBox(height: 12.0),
                        TextFormField(
                          initialValue: 'beheerder',
                          onSaved: (val) => _username = val,
                          decoration:
                          InputDecoration(labelText: "Gebruikersnaam"),
                        ),
                        SizedBox(height: 12.0),
                        TextFormField(
                          initialValue: 'beheerder12',
                          obscureText: true,
                          onSaved: (val) => _password = val,
                          decoration: InputDecoration(labelText: "Wachtwoord"),
                        ),
                        SizedBox(height: 36.0),
                        RaisedButton(
                          onPressed: _submit,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 18.0,
                              horizontal: 40.0,
                            ),
                            child: Text('Aanmelden'),
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
      ),
    );
  }
}
