import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=d75bf108";

//#5cdb95 #05386b #edf5e1

void main() async {
  print(await getData());
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //controladores para os inputs
  final controlerReal = TextEditingController();
  final controlerDolar = TextEditingController();
  final controlerEuro = TextEditingController();

  double dolar;
  double euro;

  //funcoes para quando os textos nos inputs for mudads

  void _realChange(String text) {
    if (text.isEmpty) {
      _clearInputs();
      return;
    }
    //string em double
    double real = double.parse(text);
    controlerDolar.text = (real / dolar).toStringAsFixed(2);
    controlerEuro.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChange(String text) {
    double dolar = double.parse(text);
    controlerDolar.text = (dolar * this.dolar).toStringAsFixed(2);
    controlerEuro.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChange(String text) {
    print(text);
  }

//limpar campos
  void _clearInputs() {
    controlerDolar.text = "";
    controlerEuro.text = "";
    controlerReal.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        title: Text(
          "Converter Moedas",
          style: TextStyle(
            color: Colors.tealAccent,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.green,
        bottomOpacity: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text(
                "carregando dados",
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                ),
                textAlign: TextAlign.center,
              ));

            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Alguma coisa errada, não está certa',
                    style: TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                //dados da api
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.money_off,
                        size: 100,
                        color: Colors.amberAccent,
                      ),
                      buildTextField("Quanto em reais?", "R\$", controlerReal,
                          _realChange),
                      buildTextField(
                          "Dólar", "US\$", controlerDolar, _dolarChange),
                      buildTextField("Euro", "€", controlerEuro, _euroChange),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Future<Map<dynamic, dynamic>> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

//future builder -> vai pegar oque tem no resultado do future, e vai construir um layout

//quase um mixin scss (rs)
Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function nomeFuncao) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixText: prefix,
    ),
    onChanged: nomeFuncao,
    keyboardType: TextInputType.number,
  );
}
