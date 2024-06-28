import 'package:flutter/material.dart';
import 'DynamicQRGenerator.dart';
import 'StaticDataForm.dart';
import 'get_rapport_screen.dart'; // Importez votre nouveau widget

class CodeQRScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const CodeQRScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<CodeQRScreen> createState() => _CodeQRScreenState();
}

class _CodeQRScreenState extends State<CodeQRScreen> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late String _staticData1;
  late String _staticData2;
  late String _staticData3;
  late String _staticData4;
  late String _niveauName;
  late String _moduleName;
  bool _showQRGenerator = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();

    _staticData1 = '';
    _staticData2 = '';
    _staticData3 = '';
    _staticData4 = '';
    _niveauName = '';
    _moduleName = '';
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void _handleStaticDataChange(
      String data1, String data2, String data3, String data4, String niveauName, String moduleName) {
    setState(() {
      _staticData1 = data1;
      _staticData2 = data2;
      _staticData3 = data3;
      _staticData4 = data4;
      _niveauName = niveauName;
      _moduleName = moduleName;
      _showQRGenerator = _staticData1.isNotEmpty && _staticData2.isNotEmpty && _staticData3.isNotEmpty && _staticData4.isNotEmpty;
    });
  }

  void _goBackToForm() {
    setState(() {
      _showQRGenerator = false;
    });
  }

  void _viewRapport() {
    _tabController.animateTo(2); // Changez à l'onglet "Get Rapport"
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (BuildContext context) {
          _tabController = DefaultTabController.of(context)!;
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 5,
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Static Data'),
                  Tab(text: 'Dynamic QR'),
                  Tab(text: 'Get Rapport')
                ],
              ),
            ),
            body: TabBarView(
              children: [
                StaticDataForm(
                  onStaticDataChanged: _handleStaticDataChange,
                  user: widget.user,
                ),
                _showQRGenerator
                    ? DynamicQRGenerator(
                  staticData1: _staticData1,
                  staticData2: _staticData2,
                  staticData3: _staticData3,
                  staticData4: _staticData4,
                  niveauName: _niveauName,
                  moduleName: _moduleName,
                  onBack: _goBackToForm,
                  onViewRapport: _viewRapport, // Passez la fonction à DynamicQRGenerator
                )
                    : Center(
                  child: Text(
                    'Veuillez remplir tous les champs pour générer le code QR.',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                GetRapportScreen(
                  user: widget.user,
                  staticData1: _staticData1,
                  staticData2: _staticData2,
                  staticData3: _staticData3,
                  staticData4: _staticData4,
                  niveauName: _niveauName,
                  moduleName: _moduleName,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
