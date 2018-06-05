import 'package:flutter/material.dart';

class PageLoadingIndicator extends StatelessWidget {
  final String _message;

  PageLoadingIndicator(this._message);

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      new CircularProgressIndicator(
          valueColor:
              new AlwaysStoppedAnimation(Theme.of(context).disabledColor)),
      new Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: new Text(_message,
              style: new TextStyle(color: Theme.of(context).disabledColor))),
    ]));
  }
}
