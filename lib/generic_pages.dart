import 'package:flutter/material.dart';

class PageLoadingIndicator extends StatelessWidget {
  final String _message;

  PageLoadingIndicator(this._message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation(Theme.of(context).disabledColor)),
          Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Text(_message,
                  style: TextStyle(color: Theme.of(context).disabledColor))),
        ],
      ),
    );
  }
}

class PageLoadingError extends StatelessWidget {
  final String _message;

  PageLoadingError(this._message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 52.0,
            color: Theme.of(context).disabledColor,
          ),
          Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Text(_message,
                  style: TextStyle(color: Theme.of(context).disabledColor))),
        ],
      ),
    );
  }
}
