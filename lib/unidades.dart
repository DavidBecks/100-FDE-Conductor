// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cien_conductor/common.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class Unidades extends StatefulWidget {
  @override
  _ServiciosCursoState createState() => _ServiciosCursoState();
}

class _ServiciosCursoState extends State<Unidades> {
  late Query _ref;

  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance
        .ref()
        .child('Unidades')
        .orderByChild('flotilla')
        .equalTo(Common.flotilla);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unidades registradas'),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [],
                ),
              ),
              Expanded(
                child: FirebaseAnimatedList(
                  query: _ref,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    Map? requests;
                    requests = snapshot.value as Map?;
                    return _buildMensaje(
                      requests: requests,
                      context: context,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMensaje({Map? requests, context}) {
    return InkWell(
      onTap: (() async {
        seleccionaUnidad(requests);
      }),
      child: Container(
          margin: EdgeInsets.fromLTRB(24, 20, 24, 10),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            requests?['id'],
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Color.fromARGB(255, 150, 5, 5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            requests?['conductor'] != null
                                ? 'Ocupado'
                                : 'Disponible',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Color.fromARGB(255, 12, 100, 7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Marca: ${requests?['marca']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Modelo: ${requests?['modelo']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Año: ${requests?['anio']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Color: ${requests?['color']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Combustible: ${requests?['combustible']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Comentarios: ${requests?['comentarios']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Fecha: ${requests?['fecha']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity, // Ocupa todo el ancho disponible
                height: 1, // Altura del divider
                color: const Color.fromARGB(
                    255, 223, 223, 223), // Color del divider
              ),
            ],
          )),
    );
  }

  void seleccionaUnidad(Map? requests) {
    /*if (requests?['conductor'] == null) {
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Unidad ocupada"),
      ));
    }*/
    DatabaseReference realtime = FirebaseDatabase.instance.ref("User");
    DatabaseReference unidades = FirebaseDatabase.instance.ref("Unidades");

    unidades.child(requests?['placas']).update({
      "conductor": Common.name,
    });

    realtime.child(Common.phone).update({
      "unidad":
          '${requests?['placas']}\n${requests?['marca']} ${requests?['modelo']} - ${requests?['color']}\n${requests?['combustible']}\n ${requests?['fecha']}',
    });
    Common.unidad =
        '${requests?['placas']}\n${requests?['marca']} ${requests?['modelo']} - ${requests?['color']}\n${requests?['combustible']}\n ${requests?['fecha']}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          "Unidad ${requests?['placas']} ${requests?['marca']} ${requests?['modelo']} seleccionada"),
    ));
  }
}
