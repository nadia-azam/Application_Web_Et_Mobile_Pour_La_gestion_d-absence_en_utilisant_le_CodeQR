import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../nodejs/rest_api.dart';
import 'StudentsTable.dart';

class GetRapportScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final String? staticData1;
  final String? staticData2;
  final String? staticData3;
  final String? staticData4;
  final String? niveauName;
  final String? moduleName;

  GetRapportScreen({
    Key? key,
    this.staticData1,
    this.staticData2,
    this.staticData3,
    this.staticData4,
    this.niveauName,
    this.moduleName,
    required this.user,
  }) : super(key: key);

  @override
  _RapportPdfScreenState createState() => _RapportPdfScreenState();
}

class _RapportPdfScreenState extends State<GetRapportScreen> {
  late TextEditingController _salleController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _salleController = TextEditingController(text: widget.staticData3);
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _initializeDateTime();
    _handleInputChange(); // Check if the button should be enabled initially
  }

  @override
  void dispose() {
    _salleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _initializeDateTime() {
    if (widget.staticData4 != null) {
      try {
        final dateTimePart = widget.staticData4!.split(' ');
        final parts = dateTimePart[4].split('/');
        final year = parts[0];
        final month = parts[1];
        final day = parts[2].split(' ')[0];
        final date = '$year-$month-$day';
        final timePart = dateTimePart[5];
        final timeParts = timePart.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        _dateController.text = date;
        _timeController.text = _formatHour(hour) + ':' + _formatMinute(minute) + ' ' + _getAMPM(hour);
      } catch (e) {
        print('Erreur lors de la conversion de la date et de l\'heure: $e');
      }
    }
  }

  void _handleInputChange() {
    setState(() {
      _isButtonEnabled = widget.niveauName != null &&
          widget.moduleName != null &&
          _salleController.text.isNotEmpty &&
          _dateController.text.isNotEmpty &&
          _timeController.text.isNotEmpty;
    });
  }

  void _handleSubmit() async {
    if (_isButtonEnabled) {
      try {
        DateTime parsedDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse(
            '${_dateController.text} ${_timeController.text}');

        List<Map<String, dynamic>> studentsData = await fetchStudentsData(
            widget.niveauName!, widget.moduleName!, parsedDateTime);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentsTableScreen(
              studentsData: studentsData,
              dateTime: parsedDateTime,
              module: widget.moduleName!,
              niveau: widget.niveauName!,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la récupération des données des étudiants: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tous les champs sont obligatoires!'),
        ),
      );
    }
  }

  String _formatHour(int hour) {
    if (hour > 12) {
      return (hour - 12).toString();
    } else if (hour == 0) {
      return '12';
    } else {
      return hour.toString();
    }
  }

  String _formatMinute(int minute) {
    return minute < 10 ? '0$minute' : minute.toString();
  }

  String _getAMPM(int hour) {
    return hour >= 12 ? 'PM' : 'AM';
  }

  @override
  Widget build(BuildContext context) {
    bool isDataEmpty = widget.staticData1 == '' ||
        widget.staticData2 == '' ||
        widget.staticData3 == '' ||
        widget.staticData4 == '' ||
        widget.niveauName == '' ||
        widget.moduleName == '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Rapport'),
      ),
      body: isDataEmpty
          ? Center(
        child: Text(
          'Pas encore de rapport à cet instant',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Rapport Généré',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: widget.niveauName,
              decoration: InputDecoration(
                labelText: 'Niveau',
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              enabled: false,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: widget.moduleName,
              decoration: InputDecoration(
                labelText: 'Module',
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              enabled: false,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _salleController,
              decoration: InputDecoration(
                labelText: 'Salle',
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              enabled: false,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      labelText: 'Heure',
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    enabled: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonEnabled ? _handleSubmit : null,
              child: Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}
