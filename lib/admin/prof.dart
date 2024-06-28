import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pfaa/admin/add_prof/form_ajout_prof.dart';
import 'package:pfaa/admin/edit_prof/form_edit_prof.dart';
import 'package:pfaa/admin/models/professor.dart';
import 'package:pfaa/nodejs/rest_api_prof.dart';

class ProfesseurScreen extends StatefulWidget {
  const ProfesseurScreen({Key? key}) : super(key: key);

  @override
  State<ProfesseurScreen> createState() => _ProfesseurScreenState();
}

class _ProfesseurScreenState extends State<ProfesseurScreen> {
  late List<Professor> professors = [];
  late List<Professor> filteredProfessors = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfessors();
  }

  Future<void> fetchProfessors() async {
    final List<Professor> fetchedProfessors = await RestApi.fetchProfessors();
    setState(() {
      professors = fetchedProfessors;
      filteredProfessors = List.from(professors);
    });
  }

  void filterProfessors(String query) {
    List<Professor> searchResult = professors
        .where((professor) =>
    professor.nom.toLowerCase().contains(query.toLowerCase()) ||
        professor.prenom.toLowerCase().contains(query.toLowerCase()) ||
        professor.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredProfessors = searchResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Listes des professeurs",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            width: 400,
            height: 70,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                filterProfessors(value);
              },
              decoration: InputDecoration(
                hintText: 'Chercher un prof',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.only(left: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                    headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    dataRowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                    columns: const [
                      DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Prénom', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: filteredProfessors
                        .map(
                          (professor) => DataRow(
                        cells: [
                          DataCell(Text(professor.nom)),
                          DataCell(Text(professor.prenom)),
                          DataCell(Text(professor.email)),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _showEditForm(professor.id);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showConfirmationDialog(professor.id!, professor.nom);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'Ajouter un professeur',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProfessorForm()),
              ).then((_) {
                fetchProfessors();
              });
            },
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            tooltip: 'Importer les professeurs depuis un fichier Excel',
            onPressed: _pickExcelFile,
            backgroundColor: Colors.green,
            child: const Icon(Icons.upload_file),
          ),
        ],
      ),
    );
  }

  void _showEditForm(int? id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfForm(professorId: id)),
    ).then((_) {
      fetchProfessors();
    });
  }

  void _showConfirmationDialog(int id, String nom) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer $nom ?'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce professeur ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _deleteProfessor(id);
                Navigator.of(context).pop();
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProfessor(int id) {
    Professor professorToDelete = professors.firstWhere((professor) => professor.id == id);

    RestApi.deleteProfessor(id).then((_) {
      Fluttertoast.showToast(
        msg: 'Professeur ${professorToDelete.nom} ${professorToDelete.prenom} supprimé avec succès',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      fetchProfessors();
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de la suppression du professeur',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      // Utilisez directement les bytes du fichier
      List<int> bytes = result.files.single.bytes!;

      // Appel à la méthode de lecture
      _readExcelFile(bytes);
    } else {
      // L'utilisateur n'a pas sélectionné de fichier
    }
  }

  Future<void> _readExcelFile(List<int> bytes) async {
    try {
      // Lire le contenu du fichier Excel
      var excel = Excel.decodeBytes(bytes);

      // Lire les données des professeurs
      List<Professor> newProfessors = [];
      for (var row in excel.tables[excel.tables.keys.first]!.rows.skip(1)) {
        // Convertir les valeurs des cellules en chaînes de caractères pour éviter les erreurs de type
        newProfessors.add(Professor(
          nom: row[0]?.value.toString() ?? '', // Index des colonnes à adapter selon le fichier Excel
          prenom: row[1]?.value.toString() ?? '',
          email: row[2]?.value.toString() ?? '',
          password: row[3]?.value.toString() ?? ''
          // Ajoutez d'autres attributs de Professor selon votre modèle
        ));
      }

      // Ajouter les nouveaux professeurs à la base de données
      await RestApi.addProfessorsToDatabase(newProfessors);

      // Actualiser la liste des professeurs affichés
      setState(() {
        professors.addAll(newProfessors);
        filteredProfessors.addAll(newProfessors); // Mise à jour de la liste filtrée également
      });

      // Afficher un message de succès
      Fluttertoast.showToast(
        msg: 'Professeurs importés avec succès depuis le fichier Excel',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (error) {
      // Gérer les erreurs lors de la lecture du fichier Excel
      print('Erreur lors de la lecture du fichier Excel : $error');
      Fluttertoast.showToast(
        msg: 'Erreur lors de la lecture du fichier Excel',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
