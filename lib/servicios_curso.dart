// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:cien_conductor/common.dart';
import 'package:cien_conductor/historial.dart';
import 'package:cien_conductor/mapa.dart';

class ServiciosCurso extends StatefulWidget {
  @override
  _ServiciosCursoState createState() => _ServiciosCursoState();
}

class _ServiciosCursoState extends State<ServiciosCurso> {
  late Query _ref;

  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance
        .ref()
        .child('Requests')
        .orderByChild("conductor")
        .equalTo(Common.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servicios en curso'),
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
        Common.idR = requests?['id'];
        if (requests?['nombre'] == null) {
          Common.nombreR = requests?['name'];
          Common.origenR = requests?['address'];
          Common.destinoR = requests?['addressgps'];
          Common.precio = requests?['costo'];
          Common.detalleR =
              'Nombre: ${Common.nombreR}\n\nOrigen: ${Common.origenR}\nDestino: ${Common.destinoR}\n\n${Common.precio}';
          Common.latitudOrigen = requests?['origenLati'];
          Common.longitudOrigen = requests?['origenLongi'];
          Common.latitudDestino = requests?['destinoLati'];
          Common.longitudDestino = requests?['destinoLongi'];
        } else {
          Common.nombreR = requests?['nombre'];
          Common.origenR = requests?['origen'];
          Common.destinoR = requests?['destino'];
          Common.detalleR = requests?['servicio'];
          Common.precio = requests?['precio'];
          Common.latitudOrigen = Common.latitud;
          Common.longitudOrigen = Common.longitud;
          Common.latitudDestino = requests?['latitud_destino'];
          Common.longitudDestino = requests?['longitud_destino'];
        }

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Mapa()));
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
                            requests?['conductor'],
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                child: Expanded(
                                  child: Text(
                                    requests?['nombre'] == null
                                        ? '${requests?['name']}'
                                        : '${requests?['nombre']}',
                                    style: TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            requests?['hora'],
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.arrow_right,
                    size: 24,
                    color: Colors.black,
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
}
