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
                                    color: Colors.deepPurple[900], fontSize: 16.0),
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
