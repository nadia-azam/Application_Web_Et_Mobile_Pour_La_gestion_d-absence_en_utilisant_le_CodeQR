import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../admin/DashboardAdmin.dart';
import '../nodejs/rest_api.dart';
import 'StudentsTable.dart';


class RapportPdfScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  RapportPdfScreen({Key? key, this.user}) : super(key: key);

  @override
  _RapportPdfScreenState createState() => _RapportPdfScreenState();
}

class _RapportPdfScreenState extends State<RapportPdfScreen> {
  late List<dynamic> _niveaux = [];
  late List<dynamic> _modules = [];

  String _selectedModules = '';
  String _selectedNiveau = '';
  late TextEditingController _salleController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _salleController = TextEditingController();
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _fetchNiveaux();
    _fetchModules();
  }

  @override
  void dispose() {
    _salleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _handleInputChange() {
    setState(() {
      _isButtonEnabled = _selectedModules.isNotEmpty &&
          _selectedNiveau.isNotEmpty &&
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
            _selectedNiveau, _selectedModules, parsedDateTime);

        // Naviguer vers StudentsTableScreen en passant les données nécessaires
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentsTableScreen(
              studentsData: studentsData,
              dateTime: parsedDateTime,
              module: _selectedModules,
              niveau: _selectedNiveau,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors de la récupération des données des étudiants: $e'),
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

  void _fetchNiveaux() async {
    try {
      List<String>? niveaux =
      await fetchNiveauxFromAPI(widget.user?['email']);

      setState(() {
        _niveaux = niveaux ?? [];
      });
    } catch (e) {
      print('Erreur lors de la récupération des niveaux: $e');
    }
  }

  void _fetchModules() async {
    try {
      List<String>? modules =
      await fetchModulesForProf(widget.user?['email']);

      setState(() {
        _modules = modules ?? [];
      });
    } catch (e) {
      print('Erreur lors de la récupération des modules: $e');
    }
  }

  Future<void> _showDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        _handleInputChange();
      });
    }
  }

  Future<void> _showTimePicker() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _timeController.text = selectedTime.format(context);
        _handleInputChange();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        labelText: 'Module', border: InputBorder.none),
                    items: _modules.map((module) {
                      return DropdownMenuItem<String>(
                        value: module,
                        child: Center(child: Text(module)),
                      );
                    }).toList(),
                    onChanged: (String? selectedValue) {
                      setState(() {
                        _selectedModules = selectedValue ?? '';
                        _handleInputChange();
                      });
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        labelText: 'Niveau', border: InputBorder.none),
                    items: _niveaux.map((niveau) {
                      return DropdownMenuItem<String>(
                        value: niveau,
                        child: Center(child: Text(niveau)),
                      );
                    }).toList(),
                    onChanged: (String? selectedValue) {
                      setState(() {
                        _selectedNiveau = selectedValue ?? '';
                        _handleInputChange();
                      });
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextField(
                    controller: _salleController,
                    decoration:
                    InputDecoration(labelText: 'Salle', border: InputBorder.none),
                    onChanged: (value) => _handleInputChange(),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextField(
                    controller: _dateController,
                    decoration:
                    InputDecoration(labelText: 'Date', border: InputBorder.none),
                    onTap: _showDatePicker,
                    readOnly: true,
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextField(
                    controller: _timeController,
                    decoration:
                    InputDecoration(labelText: 'Heure', border: InputBorder.none),
                    onTap: _showTimePicker,
                    readOnly: true,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isButtonEnabled ? _handleSubmit : null,
                  child: Text('Envoyer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}