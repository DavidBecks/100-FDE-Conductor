// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:async';

import 'package:cien_conductor/perfil.dart';
import 'package:cien_conductor/previa.dart';
import 'package:cien_conductor/principal.dart';
import 'package:cien_conductor/saldo.dart';
import 'package:cien_conductor/unidades.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:cien_conductor/common.dart';
import 'package:cien_conductor/historial.dart';
import 'package:cien_conductor/login.dart';
import 'package:cien_conductor/mapa.dart';
import 'package:cien_conductor/servicios_curso.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class ServiciosDisponibles extends StatefulWidget {
  @override
  _ServiciosCursoState createState() => _ServiciosCursoState();
}

//https://firebasestorage.googleapis.com/v0/b/confiable-fe601.appspot.com/o/sounds%2Fpedido.mp3?alt=media&token=d617b7ae-4d31-4d64-a271-d110e00b79de
class _ServiciosCursoState extends State<ServiciosDisponibles> {
  late Query _ref;
  AudioPlayer audioPlayer = AudioPlayer();
  late Timer _timer;

  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance.ref().child('TomarPedido').orderByKey();
    setupFirebaseListener();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _obtenerUbicacionActual();
    });
  }

  Future<void> _obtenerUbicacionActual() async {
    try {
      // Obtener la ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Obtener la fecha y hora actual en formato legible
      String fechaHoraActual =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // Escribir los datos en Firebase
      DatabaseReference referencia =
          FirebaseDatabase.instance.ref('Ubicaciones/${Common.phone}');

      await referencia.set({
        'latitud': position.latitude,
        'longitud': position.longitude,
        'phone': Common.phone,
        'name': Common.name,
        'hora': fechaHoraActual, // Guarda la fecha y hora actual
      });

      // Actualizar las coordenadas en el estado

      print('Ubicación guardada en Firebase correctamente');
    } catch (e) {
      print('Error al obtener la ubicación o guardar en Firebase: $e');
    }
  }

  void setupFirebaseListener() {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('TomarPedido');

    ref.onValue.listen((event) async {
      var snapshotValue = event.snapshot.value;

      if (snapshotValue != null) {
        print('Cambio detectado: $snapshotValue');
        playAudio();
      }
    });
  }

  void playAudio() async {
    try {
      //await audioPlayer.play(BytesSource(audioBytes));
      //https://firebasestorage.googleapis.com/v0/b/molapo-41042.appspot.com/o/mensaje.mp3?alt=media&token=d459decb-1d14-4748-8ecd-15d46c84ef6d
      await audioPlayer.play(UrlSource(
          'https://firebasestorage.googleapis.com/v0/b/confiable-fe601.appspot.com/o/sounds%2Fpedido.mp3?alt=media&token=d617b7ae-4d31-4d64-a271-d110e00b79de'));
      print("Audio reproducido.");
    } catch (e) {
      print("Error al reproducir audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servicios Disponibles'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                '${Common.name}\n${Common.tarifa}\nv5.4',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              title: Text('Generar Servicio'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MapScreen()));
              },
            ),
            ListTile(
              title: Text('Servicios en Curso'),
              onTap: () {
                // Lógica para mostrar servicios en curso
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ServiciosCurso()));
              },
            ),
            ListTile(
              title: Text('Servicios disponibles'),
              onTap: () {
                // Lógica para mostrar servicios en curso
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServiciosDisponibles()));
              },
            ),
            Common.flotilla != 'no'
                ? ListTile(
                    title: Text('Unidades'),
                    onTap: () {
                      // Lógica para mostrar servicios en curso
                      Navigator.pop(context); // Cierra el drawer
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Unidades()));
                    },
                  )
                : SizedBox(),
            ListTile(
              title: Text('Perfil'),
              onTap: () {
                // Lógica para mostrar servicios en curso
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Perfil()));
              },
            ),
            ListTile(
              title: Text('Historial'),
              onTap: () {
                // Lógica para mostrar historial
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Historial()));
              },
            ),
            Common.saldo_habilitado == 'si'
                ? ListTile(
                    title: Text('Saldo'),
                    onTap: () {
                      // Lógica para mostrar servicios en curso
                      Navigator.pop(context); // Cierra el drawer
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SaldoScreen()));
                    },
                  )
                : SizedBox(),
            ListTile(
              title: Text('Cerrar Sesión'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                await prefs.clear();
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
            /*ListTile(
              title: Text('Servidor'),
              onTap: () async {
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Servidor()));
              },
            ),*/
          ],
        ),
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
          Positioned(
            bottom: 26,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                final userRef = FirebaseDatabase.instance
                    .ref()
                    .child('User/${Common.phone}');

                try {
                  final snapshot = await userRef.child('servicio').get();

                  if (snapshot.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Debes finalizar tu servicio en curso para poder generar uno nuevo"),
                      ),
                    );
                  } else {
                    if (Common.saldo_habilitado == 'si') {
                      if (Common.saldo >= 0.0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Necesitas recargar saldo para poder seguir generando servicios"),
                          ),
                        );
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapScreen()),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "Error al verificar el servicio en curso: $e")),
                  );
                }
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.directions_car),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensaje({Map? requests, context}) {
    return InkWell(
      onTap: () async {
        final userRef =
            FirebaseDatabase.instance.ref().child('User/${Common.phone}');

        try {
          final snapshot = await userRef.child('servicio').get();

          if (snapshot.exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "Debes finalizar tu servicio en curso para poder aceptar uno nuevo"),
              ),
            );
          } else {
            if (Common.saldo_habilitado == 'si') {
              if (Common.saldo >= 0.0) {
                Common.id = requests?['id'];
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Previa()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Necesitas recargar saldo para poder seguir aceptando servicios"),
                  ),
                );
              }
            } else {
              Common.id = requests?['id'];
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Previa()),
              );
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Error al verificar el servicio en curso: $e")),
          );
        }
      },
      child: Container(
          margin: EdgeInsets.fromLTRB(8, 20, 8, 10),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/copia-servo.appspot.com/o/images%2Fperfil.png?alt=media&token=c0331739-e995-4826-915c-d9c2f98291cb'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        width: 70,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            maxLines: null,
                            '${requests?['nombre']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 8,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
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
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            maxLines: null,
                            'Origen: ${requests?['origen']}',
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
                            maxLines: null,
                            'Destino: ${requests?['destino']}',
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
                            'MXN ${requests?['precio']}',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildMensaje2({Map? requests, context}) {
    return InkWell(
      onTap: (() async {
        Common.idR = requests?['id'];
        Common.nombreR = requests?['nombre'];
        Common.numeroR = requests?['numero'];
        Common.origenR = requests?['origen'];
        Common.destinoR = requests?['destino'];
        Common.detalleR = requests?['servicio'];
        Common.latitudOrigen = requests?['latitud_origen'];
        Common.longitudOrigen = requests?['longitud_origen'];
        Common.latitudDestino = requests?['latitud_destino'];
        Common.longitudDestino = requests?['longitud_destino'];

        DatabaseReference curso =
            FirebaseDatabase.instance.ref("Requests").child(Common.idR);
        curso.update({"conductor": Common.name, "status": 'Servicio asignado'});
        DatabaseReference backup =
            FirebaseDatabase.instance.ref("Backup").child(Common.idR);
        backup.update({"conductor": Common.name});
        DatabaseReference borrar_pendiente =
            FirebaseDatabase.instance.ref("Servicio").child(Common.idR);
        borrar_pendiente.remove();
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
                            requests?['grua'],
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
                              child: Text(
                                'Marca: ${requests?['marca']} modelo: ${requests?['modelo']}',
                                style: TextStyle(
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Origen: ${requests?['origen']}',
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
                            'Destino: ${requests?['destino']}',
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
                            requests?['hora'],
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'MXN ${requests?['precio']}',
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
