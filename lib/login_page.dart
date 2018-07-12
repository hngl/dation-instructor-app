import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:instructorapp/main.dart';

class LoginPage extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  LoginPage({Key key, this.analytics, this.observer}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState(analytics, observer);
  }
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  String _username;
  String _password;
  String _handle;

  _LoginPageState(this.analytics, this.observer);

  void _submit() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
    }

    // Log usage
    analytics.setUserId("$_username@$_handle");
    analytics.setUserProperty(name: 'handle', value: _handle);
    analytics.logLogin();

    debugPrint("Submitted $_username@$_handle:$_password");
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
        splashColor: Theme.of(context).splashColor,
        buttonColor: Colors.white,
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/graphics/adventure-agriculture-auto-754595.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Image.asset(
                        'assets/graphics/logo_white.png',
                      ),
                    ),
                    SizedBox(height: 18.0),
                    Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            initialValue: 'dation',
                            onSaved: (val) => _handle = val,
                            decoration: InputDecoration(labelText: "Rijschool"),
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
                            decoration:
                                InputDecoration(labelText: "Wachtwoord"),
                          ),
                          SizedBox(height: 36.0),
                          RaisedButton(
                            onPressed: _submit,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 40.0),
                              child: Text(
                                'Aanmelden',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor, fontSize: 16.0),
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
