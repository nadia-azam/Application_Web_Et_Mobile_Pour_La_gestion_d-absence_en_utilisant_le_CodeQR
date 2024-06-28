import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRResult extends StatelessWidget {
  final String code;
  final Function() closeScreen;

  const QRResult({
    super.key,
    required this.code,
    required this.closeScreen,
  });

  @override
  Widget build(BuildContext context) {
    // Suppose the QR code data is structured with newline as delimiter
    List<String> qrData = code.split('\n');
    String module = qrData.length > 0 ? qrData[0] : 'Unknown';
    String niveau = qrData.length > 1 ? qrData[1] : 'Unknown';
    String salle = qrData.length > 2 ? qrData[2] : 'Unknown';
    String dateTime = qrData.length > 3 ? qrData[3] : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        leading: IconButton(
          onPressed: () {
            closeScreen();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(
          "Scanned Result",
          style: TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(60),
        child: Column(
          children: [
            SizedBox(
              height: 120,
            ),
            QrImageView(
              data: code,
              size: 300,
              version: QrVersions.auto,
            ),
            Text(
              "Scanned QR",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Module: $module\nNiveau: $niveau\nSalle: $salle\nDate et Heure: $dateTime",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 150,
              height: 60,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade900
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                  },
                  child: Text(
                    "Copy",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
