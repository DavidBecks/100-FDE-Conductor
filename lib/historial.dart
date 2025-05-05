// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:cien_conductor/common.dart';
import 'package:cien_conductor/mapa.dart';

class Historial extends StatefulWidget {
  @override
  _ServiciosCursoState createState() => _ServiciosCursoState();
}

class _ServiciosCursoState extends State<Historial> {
  late Query _ref;

  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance
        .ref()
        .child('BackUpRequests')
        .orderByChild("conductor")
        .equalTo(Common.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de servicios'),
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
      onTap: (() async {}),
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
                            requests?['hora'],
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            requests?['origen'] != null
                                ? 'Origen: ${requests?['origen']}'
                                : 'Origen: ${requests?['address']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            requests?['destino'] != null
                                ? 'Destino: ${requests?['destino']}'
                                : 'Destino: ${requests?['addressgps']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            requests?['precio'] != null
                                ? 'MXN ${requests?['precio']}'
                                : 'MXN ${requests?['costo']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 18,
                              color: Colors.black,
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
}
