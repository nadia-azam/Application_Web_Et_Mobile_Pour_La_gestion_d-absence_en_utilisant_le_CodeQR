import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pfaa/nodejs/utils.dart';
import 'package:pfaa/admin/models/professor.dart';


class RestApi {

  static Future<List<Professor>> fetchProfessors() async {
    final response = await http.get(
        Uri.parse('${Utils.baseUrl}/crud/professors'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Professor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load professors');
    }
  }

  static Future<Professor> fetchProfessor(int? id) async {
    final response = await http.get(
        Uri.parse('${Utils.baseUrl}/crud/professor/$id'));
    print('${Utils.baseUrl}/crud/professor/$id');
    print(Professor.fromJson(json.decode(response.body)));
    if (response.statusCode == 200) {
      print("pa de prof");
      return Professor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load professor');
    }
  }


  static Future<void> addProfessor(String nom, String prenom, String email,
      String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/crud/addProfessor'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(
          {'nom': nom, 'prenom': prenom, 'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add professor');
    }
  }

  static Future<void> deleteProfessor(int id) async {
    final response = await http.delete(
        Uri.parse('${Utils.baseUrl}/crud/deleteProfessor/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete professor');
    }
  }

  static Future<void> updateProfessor(int id, String nom, String prenom,
      String email, String password) async {
    final response = await http.put(
      Uri.parse('${Utils.baseUrl}/crud/updateProfessor/$id'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(
          {'nom': nom, 'prenom': prenom, 'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update professor');
    }
  }


  static Future<void> addProfessorsToDatabase(
      List<Professor> professors) async {
    final List<Map<String, dynamic>> professorsData = professors.map((
        professor) =>
    {
      'nom': professor.nom,
      'prenom': professor.prenom,
      'email': professor.email,
      'password': professor.password,
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/crud/liste_professeurs'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(professorsData),
      );

      if (response.statusCode == 200) {
        print('Professeurs ajoutés avec succès à la base de données.');
        Fluttertoast.showToast(
          msg: 'Professeurs ajoutés avec succès à la base de données.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        print(
            'Erreur lors de l\'ajout des professeurs à la base de données : ${response
                .body}');
        Fluttertoast.showToast(
          msg: 'Erreur lors de l\'ajout des professeurs à la base de données.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error) {
      print('Erreur lors de l\'envoi de la requête HTTP : $error');
      Fluttertoast.showToast(
        msg: 'Erreur lors de l\'envoi de la requête HTTP.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

}
