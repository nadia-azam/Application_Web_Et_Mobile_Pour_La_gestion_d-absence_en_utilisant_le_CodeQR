import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pfaa/student/qr_scan_page.dart';
import 'package:pfaa/student/profil_student.dart';
import 'package:pfaa/screens/login/login_widget.dart';
import 'package:pfaa/nodejs/utils.dart';

enum SideBarItem {
  Modules,
  Profil,
  Scanner,
  Logout,
}

final sideBarItemProvider = StateProvider<SideBarItem>((ref) => SideBarItem.Modules);

class DashboardStudent extends ConsumerStatefulWidget {
  final Map<String, dynamic>? user;

  const DashboardStudent({Key? key, this.user}) : super(key: key);

  @override
  _DashboardStudentState createState() => _DashboardStudentState();
}

class _DashboardStudentState extends ConsumerState<DashboardStudent> {
  String _userLevel = '';
  List<Module> _modules = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchStudentInfo();
    fetchModules();
  }

  Future<void> fetchModules() async {
    try {
      final userId = widget.user!['id'];
      final modules = await fetchStudentModules(userId);
      setState(() {
        _modules = modules;
      });
    } catch (error) {
      print("Error fetching modules: $error");
    }
  }

  Future<List<Module>> fetchStudentModules(int studentId) async {
    try {
      final response = await http.get(Uri.parse('${Utils.baseUrl}/crud/level/$studentId'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final modulesData = jsonData['modules'] as List;
        return modulesData.map((moduleJson) => Module.fromJson(moduleJson as Map<String, dynamic>)).toList();
      } else {
        print('Échec de la récupération des modules: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Erreur lors de la récupération des modules: $error');
      return [];
    }
  }

  Future<void> fetchStudentInfo() async {
    try {
      final userId = widget.user!['id'];
      final response = await http.get(Uri.parse('${Utils.baseUrl}/moduleStudent/info/$userId'));
      final data = jsonDecode(response.body);
      final userLevel = data['niveau'];
      setState(() {
        _userLevel = userLevel;
      });
    } catch (error) {
      print("Error fetching student info: $error");
    }
  }

  Widget getBodyForItem(SideBarItem item) {
    switch (item) {
      case SideBarItem.Modules:
        return ModulesScreen(modules: _modules, searchQuery: _searchQuery, onSearchQueryChanged: (query) {
          setState(() {
            _searchQuery = query.toLowerCase();
          });
        });
      case SideBarItem.Profil:
        return ProfilScreen(user: widget.user ?? {});
      case SideBarItem.Scanner:
        return QRScanner(user: widget.user ?? {});
      case SideBarItem.Logout:
        return LoginWidget();
    }
  }

  SideBarItem getSideBarItem1(AdminMenuItem item) {
    for (var value in SideBarItem.values) {
      if (item.route == value.toString().split('.').last) {
        return value;
      }
    }
    return SideBarItem.Modules;
  }

  final Map<SideBarItem, IconData> sideBarItemIcons = {
    SideBarItem.Modules: Icons.book,
    SideBarItem.Profil: Icons.person,
    SideBarItem.Scanner: Icons.qr_code,
    SideBarItem.Logout: Icons.logout,
  };

  @override
  Widget build(BuildContext context) {
    final sideBarItem = ref.watch(sideBarItemProvider);
    final sideBarkey = ValueKey(Random().nextInt(1000000));

    return AdminScaffold(
      appBar: AppBar(
        title: const Text('Espace Étudiant'),
        backgroundColor: Colors.indigoAccent,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      sideBar: SideBar(
        key: sideBarkey,
        backgroundColor: Colors.white,
        borderColor: Colors.white,
        textStyle: const TextStyle(color: Colors.black, fontSize: 14),
        activeTextStyle: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        activeBackgroundColor: const Color(0xFF1976D2),
        header: Container(
          height: 150,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/student1.jpg'),
                radius: 50,
              ),
              SizedBox(height: 15),
              Text(
                widget.user != null ? '${widget.user!['nom']} ${widget.user!['prenom']}' : '',
                style: const TextStyle(fontSize: 20, letterSpacing: 3, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        onSelected: (item) {
          ref.read(sideBarItemProvider.notifier).state = getSideBarItem1(item!);
        },
        items: SideBarItem.values
            .map((e) => AdminMenuItem(
            title: e.toString().split('.').last,
            icon: sideBarItemIcons[e],
            route: e.toString().split('.').last))
            .toList(),
        selectedRoute: sideBarItem.name.toString().split('.').last,
        footer: Container(
          height: 50,
          width: double.infinity,
          child: SideBar(
            backgroundColor: Colors.white,
            textStyle: const TextStyle(color: Colors.black, fontSize: 16),
            borderColor: Colors.white,
            items: const [
              AdminMenuItem(
                title: 'Log out',
                route: '/login',
                icon: Icons.logout,
              ),
            ],
            selectedRoute: '/',
            onSelected: (item) {
              if (item!.route != null) {
                Navigator.of(context).pushNamed(item.route!);
              }
            },
          ),
        ),
      ),
      body: getBodyForItem(sideBarItem),
    );
  }
}

class Module {
  final String name;
  final String description;
  final String nom_prof;
  final IconData icon;

  Module(this.name, this.description, this.nom_prof, this.icon);

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      json['nom'],
      json['description'],
      json['nom_prof'],
      Icons.book, // You can replace this with the actual icon fetched from the API if available
    );
  }
}

class ModulesScreen extends StatelessWidget {
  final List<Module> modules;
  final String searchQuery;
  final ValueChanged<String> onSearchQueryChanged;

  ModulesScreen({required this.modules, required this.searchQuery, required this.onSearchQueryChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.transparent),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher des modules',
                  prefixIcon: Icon(Icons.search, color: Colors.indigoAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: onSearchQueryChanged,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                if (searchQuery.isEmpty || module.name.toLowerCase().contains(searchQuery)) {
                  return Card(
                    child: InkWell(
                      onTap: () {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.info,
                          animType: AnimType.bottomSlide,
                          title: "Informations : ",
                          desc: "Nom : ${module.name} \n Nom du Professeur : ${module.nom_prof} \n Description : ${module.description}",
                          btnOkText: 'Fermer',
                          width: 600,
                          btnOkOnPress: () {},
                        ).show();
                      },
                      child: ListTile(
                        leading: Icon(
                          module.icon,
                          color: Colors.indigoAccent,
                          size: 50,
                        ),
                        title: Text(
                          module.name,
                          style: TextStyle(color: Colors.indigoAccent),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
