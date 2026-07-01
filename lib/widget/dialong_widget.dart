import 'package:flutter/material.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';

enum SnackBarType { success, alert, error }

class Dialogs {
  Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Loading...",
                      style: TextStyle(fontSize: 14),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> showSnackbar({
    required BuildContext context,
    required String title,
    required String message,
    required SnackBarType snackBarType,
  }) async {
    Color backgroundColor;
    IconData icon;

    switch (snackBarType) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case SnackBarType.alert:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
    }

    final snackBar = SnackBar(
      elevation: 4,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<void> showConfirmDialog(BuildContext context, GlobalKey key,
      String subtitle, void action()) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Row(children: [
            Icon(
              Icons.info_outline,
              color: Colors.orangeAccent,
            ),
            Text(
              ' Konfirmasi',
              style: TextStyle(color: Colors.black54),
            )
          ]),
          content: Text(
            subtitle,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Tidak, Batalkan!",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                action();
              },
              child: Text(
                "Ya, Lanjut!",
                style: TextStyle(
                  color: PalletConfig.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
