import 'package:flutter/material.dart';



class OneRapport extends StatefulWidget {
  const OneRapport({super.key, required String email});

  @override
  State<OneRapport> createState() => _OneRapportState();
}

class _OneRapportState extends State<OneRapport> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("LE Rapport d' aujourd'hui"));
  }
}
