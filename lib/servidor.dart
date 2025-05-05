// ignore_for_file: avoid_print, prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, non_constant_identifier_names

import 'dart:convert';

import 'package:cien_conductor/common.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;

class Servidor extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Servidor> {
  final TextEditingController _origenController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _tiempoController = TextEditingController();
  final TextEditingController _distanciaController = TextEditingController();

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  String latitudOrigen = '';
  String longitudOrigen = '';
  String latitudDestino = '';
  String longitudDestino = '';
  String phone = '';
  String id = '';

  @override
  void initState() {
    super.initState();
    _listenToFirebase();
  }

  void _listenToFirebase() {
    _databaseReference.child('Servidor/id').onValue.listen((event) {
      id = event.snapshot.value.toString();
      Future.delayed(Duration(seconds: 1), () {
        _calcula();
      });
    });
    _databaseReference.child('Servidor/phone').onValue.listen((event) {
      phone = event.snapshot.value.toString();
    });
    _databaseReference.child('Servidor/latitudOrigen').onValue.listen((event) {
      latitudOrigen = event.snapshot.value.toString();
      print('Latitud Origen: $latitudOrigen');
    });
    _databaseReference.child('Servidor/longitudOrigen').onValue.listen((event) {
      longitudOrigen = event.snapshot.value.toString();
      print('Longitud Origen: $longitudOrigen');
    });
    _databaseReference.child('Servidor/latitudDestino').onValue.listen((event) {
      latitudDestino = event.snapshot.value.toString();
      print('Latitud Destino: $latitudDestino');
    });
    _databaseReference
        .child('Servidor/longitudDestino')
        .onValue
        .listen((event) {
      longitudDestino = event.snapshot.value.toString();
      print('Longitud Destino: $longitudDestino');
    });

    //foranea();
  }

  void _calcula() {
    print("Iniciando _calcula()");
    print("latitudOrigen: $latitudOrigen");
    print("longitudOrigen: $longitudOrigen");
    print("latitudDestino: $latitudDestino");
    print("longitudDestino: $longitudDestino");

    // Verificar que las coordenadas no estén vacías
    if (latitudOrigen.isNotEmpty &&
        longitudOrigen.isNotEmpty &&
        latitudDestino.isNotEmpty &&
        longitudDestino.isNotEmpty) {
      print("Todas las coordenadas están completas.");

      LatLng origen =
          LatLng(double.parse(latitudOrigen), double.parse(longitudOrigen));
      print("Origen calculado: $origen");

      LatLng destino =
          LatLng(double.parse(latitudDestino), double.parse(longitudDestino));
      print("Destino calculado: $destino");

      _obtenerRuta(origen, destino);
      print("Llamada a _obtenerRuta completada.");
    } else {
      print("Error: Una o más coordenadas están vacías.");
    }
  }

  Future<void> _obtenerRuta(LatLng origen, LatLng destino) async {
    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origen.latitude},${origen.longitude}&'
        'destination=${destino.latitude},${destino.longitude}&'
        'key=API_KEY';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'OK') {
        /*List<LatLng> puntosRuta =
            _decodePoly(data['routes'][0]['overview_polyline']['points']);

        setState(() {
          _rutaPolylines.clear();
          _rutaPolylines.add(Polyline(
            polylineId: PolylineId('ruta'),
            points: puntosRuta,
            width: 4,
            color: Colors.black,
          ));
        });

        LatLngBounds bounds = _crearLimitesParaRuta(puntosRuta);
        _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));*/

        String distanciaTexto =
            data['routes'][0]['legs'][0]['distance']['text'];
        double distanciaEnKm = double.parse(distanciaTexto.split(' ')[0]);

        if (distanciaEnKm <= Common.cobertura) {
          Common.costo = Common.minimo;
        } else {
          Common.costo =
              (distanciaEnKm - Common.cobertura).ceil() * Common.kilometro +
                  Common.minimo;
        }
        String duracionTexto = data['routes'][0]['legs'][0]['duration']['text'];
        print(
            '---- Distancia: $distanciaTexto, Duración: $duracionTexto, Costo: ${Common.costo}');
        _totalController.text = 'Costo: \$${Common.costo}';
        DatabaseReference curso =
            FirebaseDatabase.instance.ref("Calculos/$phone");
        curso.update({
          "costo": '${Common.costo}',
          "distancia": '$distanciaTexto, $duracionTexto'
        });
        _distanciaController.text =
            'Distancia: $distanciaTexto, tiempo: $duracionTexto';
      } else {
        print('Error al obtener la ruta: ${data['status']}');
      }
    } else {
      print('Error en la solicitud de dirección: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _origenController.dispose();
    _destinoController.dispose();
    _totalController.dispose();
    _tiempoController.dispose();
    _distanciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servidor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _origenController,
              decoration: InputDecoration(
                labelText: 'Origen',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _destinoController,
              decoration: InputDecoration(
                labelText: 'Destino',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _totalController,
              decoration: InputDecoration(
                labelText: 'Total',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _tiempoController,
              decoration: InputDecoration(
                labelText: 'Tiempo',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _distanciaController,
              decoration: InputDecoration(
                labelText: 'Distancia',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> foranea() async {
    final zonas = FirebaseDatabase.instance.ref();
    final snapshot_zonas = await zonas.child('Motivos').get();

    if (snapshot_zonas.exists) {
      Common.minimo =
          int.parse(snapshot_zonas.child('minimo').value.toString());
      Common.kilometro =
          int.parse(snapshot_zonas.child('kilometro').value.toString());
    }
  }
}
