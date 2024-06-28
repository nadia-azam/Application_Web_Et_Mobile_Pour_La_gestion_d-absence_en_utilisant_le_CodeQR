import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../nodejs/utils.dart';

import 'module/form_ajout_module.dart';




class ModuleScreen extends StatefulWidget {
  final int id;
  final String nom;
  final VoidCallback hideModuleScreen;

  ModuleScreen({required this.id, required this.nom, required this.hideModuleScreen, Key? key}) : super(key: key);

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  List<dynamic> modules = [];
  List<dynamic> filteredModules = [];
  String _searchQuery = '';

  Future<void> fetchModules() async {
    try {
      var niveauId = widget.id ;
      final response = await http.get(Uri.parse('${Utils.baseUrl}/crud/modules/$niveauId'));

      if (response.statusCode == 200) {
        setState(() {
          modules = jsonDecode(response.body);
          filteredModules = List.from(modules);
        });
      } else {
        throw Exception('Failed to load modules');
      }
    } catch (error) {
      print('Error fetching modules: $error');
    }
  }

  Future<void> deleteModule(String moduleName) async {
    int niveauId= widget.id ;
    try {
      final response = await http.delete(
        Uri.parse('${Utils.baseUrl}/crud/deleteModule/$niveauId/$moduleName'),
      );
      if (response.statusCode == 200) {
        fetchModules();
      } else {
        throw Exception('Failed to delete module');
      }
    } catch (error) {
      print('Error deleting module: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchModules();

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      widget.hideModuleScreen();
                    },
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Module de ${widget.nom}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),

              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.all(16.0),
                width: 400,
                height: 70,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    filterModuleNames(); // Appel de la méthode de filtrage après la mise à jour de _searchQuery
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Module',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.only(left: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: filteredModules.map<Widget>((module) {
                  return GestureDetector(
                    onTap: () {
                      fetchModules();
                      if (module['nom'] != null) {
                        fetchModules();
                        _showModuleDetailsDialog(context, module);
                      } else {
                        // Gérer le cas où le nom du module est null
                        print("Le nom du module est null.");
                      }
                    },
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 100,
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(module['nom'] ?? ''), // Utilisation de ?? pour fournir une valeur par défaut si module['nom'] est null
                                  Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showEditModuleDialog(context,module);
                                  fetchModules();
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red,),
                                onPressed: () {
                                  // Gérer la suppression du module ici
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context){
                                        return AlertDialog(
                                          title: Text("Confirmation"),
                                          content: Text(
                                              "Voulez-vous vraiment supprimer le module : ${module['nom']} du niveau ${widget.nom}?"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text("Annuler"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Supprimer"),
                                              onPressed: () {
                                                deleteModule(module['nom'] ?? ''); // Utilisation de ?? pour fournir une valeur par défaut si module['nom'] est null
                                                fetchModules();
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              // Ajoutez un espacement en bas pour éviter un dépassement
              SizedBox(height: 50),
            ],
          ),
        ),

        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            alignment: Alignment.centerRight,
            child: FloatingActionButton(
              tooltip: 'ajouter un Module',
              onPressed: () {
                Route route = MaterialPageRoute(builder: (_) => FormModuleWidget(id: widget.id, nom: widget.nom));
                Navigator.pushReplacement(context, route);
              },
              child: const Icon(Icons.add),
              backgroundColor: Colors.blue[700],
            ),
          ),
        ),
      ],
    );





  }

  // Méthode pour afficher les détails du module dans une boîte de dialogue
  void _showModuleDetailsDialog(BuildContext context, dynamic module) {
    fetchModules();
    if (module == null) {
      return; // Sortie de la méthode si module est null
    }

    if (module == null || module['nom'] == null || module['salle'] == null || module['email_prof'] == null || module['description'] == null) {
      print('Les détails du module sont incomplets ou null.');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(20),
          title: Text('Détails du module', style: TextStyle(color: Colors.black)), // Titre en bleu
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Libellé "Nom du module" et Réponse sur la même ligne
              Row(
                children: [
                  // Libellé "Nom du module" en bleu
                  Text('Nom du module:', style: TextStyle(color: Colors.blue)),
                  SizedBox(width: 10), // Espacement entre le libellé et la réponse
                  // Réponse "Nom du module" en noir
                  Text('${module['nom'] ?? 'N/A'}', style: TextStyle(color: Colors.black)),
                ],
              ),
              SizedBox(height: 10), // Espacement entre les paires de libellé et de réponse
              // Libellé "Salle" et Réponse sur la même ligne
              Row(
                children: [
                  // Libellé "Salle" en bleu
                  Text('Salle:', style: TextStyle(color: Colors.blue)),
                  SizedBox(width: 5), // Espacement entre le libellé et la réponse
                  // Réponse "Salle" en noir
                  Text('${module['salle'] ?? 'N/A'}', style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10), // Espacement entre les paires de libellé et de réponse
              // Libellé "Professeur" et Réponse sur la même ligne
              Row(
                children: [
                  // Libellé "Professeur" en bleu
                  Text('Professeur:', style: TextStyle(color: Colors.blue)),
                  SizedBox(width: 5), // Espacement entre le libellé et la réponse
                  // Réponse "Professeur" en noir
                  FutureBuilder(

                    future: module['email_prof'] != null ? _fetchProfessorName(module['email_prof']) : null,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Erreur: ${snapshot.error}', style: TextStyle(color: Colors.black)); // En noir en cas d'erreur
                      } else {
                        // Vérifier si 'data' est null avant d'afficher
                        return Text('${snapshot.data?.toString().toUpperCase() ?? 'N/A'}', style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold));
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 10), // Espacement entre les paires de libellé et de réponse
              // Libellé "Description" et Réponse sur la même ligne
              Row(
                children: [
                  // Libellé "Description" en bleu
                  Text('Description:', style: TextStyle(color: Colors.blue)),
                  SizedBox(width: 5), // Espacement entre le libellé et la réponse
                  // Réponse "Description" en noir
                  Text('${module['description'] ?? 'N/A'}', style: TextStyle(color: Colors.black)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );

      },
    );
  }



  Future<String> _fetchProfessorName(String emailProf) async {
    try {
      final response = await http.get(
        Uri.parse('${Utils.baseUrl}/crud/professor/$emailProf'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final fullName = data['fullName'] as String?;
        if (fullName != null) {
          return fullName;
        } else {
          throw Exception('Full name is null or not a string');
        }
      } else {
        throw Exception('Failed to load professor name');
      }
    } catch (error) {
      print('Error fetching professor name: $error');
      throw error;
    }
  }




  void _showEditModuleDialog(BuildContext context, dynamic module) {
    String salle = module['salle'] ?? '';
    String emailProf = module['email_prof'] ?? '';
    String description = module['description'] ?? '';

    TextEditingController salleController = TextEditingController(text: salle);
    TextEditingController emailProfController = TextEditingController(text: emailProf);
    TextEditingController descriptionController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            title: Text('Modifier le module'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: salleController,
                  decoration: InputDecoration(
                    labelText: 'Salle',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: emailProfController,
                  decoration: InputDecoration(
                    labelText: 'Compte du professeur',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Annuler'),
              ),
              Container(
                color: Colors.blue,
                child: TextButton(
                  onPressed: () async {
                    // Faire la mise à jour dans la base de données ici
                    String newSalle = salleController.text;
                    String newEmailProf = emailProfController.text;
                    String newDescription = descriptionController.text;

                    // Faire la requête de mise à jour ici
                    await updateModule(module['nom'], newSalle, newEmailProf, newDescription); // Attendre la mise à jour
                    fetchModules(); // Mettre à jour les données
                    // Après avoir mis à jour, vous pouvez fermer la boîte de dialogue et afficher les détails du module mis à jour
                    Navigator.of(context).pop();

                  },
                  child: Text('Enregistrer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Future<void> updateModule(String moduleName, String newSalle, String newEmailProf, String newDescription) async {
    try {
      final response = await http.put(
        Uri.parse('${Utils.baseUrl}/crud/updateModule/$moduleName'),
        body: jsonEncode({
          'moduleName': moduleName,
          'newSalle': newSalle,
          'newEmailProf': newEmailProf,
          'newDescription': newDescription,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        // La mise à jour a réussi
        print('Module mis à jour avec succès.');
      } else {
        throw Exception('Failed to update module');
      }
    } catch (error) {
      print('Error updating module: $error');

    }
  }


  // Méthode pour filtrer les modules en fonction du nom



  //search
  //search
  void filterModuleNames() {
    setState(() {
      if (_searchQuery.isEmpty) {
        filteredModules = List.from(modules); // Réinitialiser la liste filtrée avec la liste complète
      } else {
        filteredModules = modules.where((niveau) {
          return niveau['nom'].toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
    });
  }











}
