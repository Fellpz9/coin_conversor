import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=2a34b926";

void main() async{
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        useMaterial3: true, 
        colorScheme: ColorScheme.fromSeed(
        seedColor: Color.fromARGB(255, 199, 164, 9) 
      ),
      )
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0, euro = 0;

  void _clearValues(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChange(String text){
    if (text.isEmpty){
      _clearValues();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChange(String text){
    if (text.isEmpty){
      _clearValues();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar/euro).toStringAsFixed(2);
  }

  void _euroChange(String text){
    if (text.isEmpty){
      _clearValues();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro/dolar).toStringAsFixed(2);
  }

  Widget buildTextFormField(String label, String prefix, TextEditingController controller, Function function){
    return TextField(
      onChanged:(value) => function(value),
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 199, 164, 9)),
        border:  const OutlineInputBorder(),
        prefixText: "$prefix ",
      ),
      style: const TextStyle(
        color: Color.fromARGB(255, 199, 164, 9),
        fontSize: 25,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 51, 51, 51),
      appBar: AppBar(
        title: const Text("Coin Converter \$\$\$"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context,snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Center(
                  child:Text(
                    "Carregando...",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 199, 164, 9),
                      ),
                    textAlign: TextAlign.center,
                  )
              );
            default:
              if(snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao carregar os dados!",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 199, 164, 9),
                      ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.monetization_on_outlined,
                        size: 125,
                        color: Color.fromARGB(255, 199, 164, 9),
                      ),
                      buildTextFormField(
                        "Real", "R\$", realController, _realChange
                      ),
                      const Divider(),
                      buildTextFormField(
                        "Dolar", "US\$", dolarController, _realChange
                      ),
                      const Divider(),
                      buildTextFormField(
                        "Euro", "EUR", euroController, _realChange
                      ),
                    ],
                  ),
                );
              }
          }
        }
      ),
    );
  }
}