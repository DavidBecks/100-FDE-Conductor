// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_collection_literals, avoid_unnecessary_containers, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print

import 'dart:convert';

import 'package:cien_conductor/common.dart';
import 'package:cien_conductor/mapa.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Previa extends StatefulWidget {
  @override
  _ServicioPasajeroState createState() => _ServicioPasajeroState();
}

class _ServicioPasajeroState extends State<Previa> {
  late DatabaseReference ref;
  late GoogleMapController mapController;
  final LatLng _initialPosition =
      LatLng(Common.latitud, Common.longitud); // Ciudad de México
  Map<PolylineId, Polyline> polylines = {};
  double total2 = 0.0;
  double total3 = 0.0;
  double total4 = 0.0;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> marcarRuta(LatLng origen, LatLng destino) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origen.latitude},${origen.longitude}&destination=${destino.latitude},${destino.longitude}&key=AIzaSyDZghHfi0xyU2rNHUYvMWmXDKXxxaTB-dM';

    print("URL para obtener la ruta: $url"); // Debug: Mostrar URL

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print(
          "Respuesta de la API: ${data}"); // Debug: Mostrar respuesta completa

      if ((data['routes'] as List).isNotEmpty) {
        final route = data['routes'][0]['overview_polyline']['points'];
        final distancia = data['routes'][0]['legs'][0]['distance']['text'];
        final duracion = data['routes'][0]['legs'][0]['duration']['text'];

        print("Ruta obtenida: $route"); // Debug: Mostrar ruta codificada
        print("Distancia: $distancia"); // Debug: Mostrar distancia
        print("Duración: $duracion"); // Debug: Mostrar duración

        final polylinePoints = _decodePolyline(route);
        print(
            "Puntos decodificados: $polylinePoints"); // Debug: Mostrar puntos decodificados

        _setPolyline(polylinePoints);

        setState(() {});
      } else {
        print("No se encontraron rutas en la respuesta de la API.");
      }
    } else {
      print("Error en la solicitud de la API: ${response.statusCode}");
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> coordinates = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final latitude = lat / 1E5;
      final longitude = lng / 1E5;
      coordinates.add(LatLng(latitude, longitude));
    }

    print(
        "Coordenadas decodificadas: $coordinates"); // Debug: Mostrar coordenadas decodificadas
    return coordinates;
  }

  void _setPolyline(List<LatLng> points) {
    final PolylineId id = PolylineId('route');
    final Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: points,
      width: 2,
    );

    setState(() {
      polylines[id] = polyline;
    });

    print("Polilínea añadida: $polyline"); // Debug: Mostrar polilínea añadida
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref = FirebaseDatabase.instance.ref('TomarPedido/${Common.id}/total');
    leerServicio();
  }

  @override
  void dispose() {
    // Es recomendable cancelar el listener cuando no se necesite
    ref.onDisconnect();
    super.dispose();
  }

  Set<Marker> _markers = {};

  Future<void> agregarMarcadores(LatLng origen, LatLng destino) async {
    print("Cargando algon......");
    try {
      print("Cargando ícono del origen...");
      BitmapDescriptor origenIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(28, 28)),
        'assets/punto_a.png',
      );
      print("Ícono del origen cargado correctamente.");

      print("Cargando ícono del destino...");
      BitmapDescriptor destinoIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(28, 28)),
        'assets/punto_b.png',
      );
      print("Ícono del destino cargado correctamente.");

      Marker marcadorOrigen = Marker(
        markerId: MarkerId('origen'),
        position: origen,
        icon: origenIcon,
      );

      Marker marcadorDestino = Marker(
        markerId: MarkerId('destino'),
        position: destino,
        icon: destinoIcon,
      );

      // Agregamos los marcadores al set
      setState(() {
        print("Agregando marcador de origen...");
        _markers.add(marcadorOrigen);
        print("Marcador de origen agregado.");

        print("Agregando marcador de destino...");
        _markers.add(marcadorDestino);
        print("Marcador de destino agregado.");
      });
    } catch (e) {
      print("Error al agregar marcadores: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Mapa ocupando la mitad superior
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              markers: _markers,
              polylines: Set<Polyline>.of(polylines.values),
            ),
          ),

          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),

                // Texto en negrita blanco
                Text(
                  'Buscando conductor',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10.0),

// Row con imagen y texto
                Row(
                  children: [
                    Image.asset('assets/punto_a.png', width: 16, height: 16),
                    SizedBox(width: 10.0),
                    Expanded(
                      // Usa Expanded para que el texto ocupe el espacio disponible
                      child: Text(
                        Common.direccionOrigen,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                        maxLines: null, // Permite múltiples líneas
                        softWrap: true, // Envuelve el texto si es necesario
                        overflow: TextOverflow
                            .visible, // Asegúrate de que el texto no se corte
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.0),

// Row con imagen y texto
                Row(
                  children: [
                    Image.asset('assets/punto_b.png', width: 16, height: 16),
                    SizedBox(width: 10.0),
                    Expanded(
                      // Usa Expanded para que el texto ocupe el espacio disponible
                      child: Text(
                        Common.direccionDestino,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                        maxLines: null, // Permite múltiples líneas
                        softWrap: true, // Envuelve el texto si es necesario
                        overflow: TextOverflow
                            .visible, // Asegúrate de que el texto no se corte
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.0),

                // Texto en negrita blanco

                SizedBox(height: 10.0),

                // Row con Text y Imagen
                Row(
                  children: [
                    Text(
                      'MXN ${Common.total}',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                  ],
                ),

                SizedBox(height: 10.0),
                SizedBox(
                  width: double.infinity, // Ancho total
                  child: ElevatedButton(
                    onPressed: () async {
                      DatabaseReference requests =
                          FirebaseDatabase.instance.ref("Requests");
                      DatabaseReference back =
                          FirebaseDatabase.instance.ref("BackUpRequests");
                      DatabaseReference disponibles =
                          FirebaseDatabase.instance.ref("TomarPedido");
                      DatabaseReference userRef =
                          FirebaseDatabase.instance.ref("User/${Common.phone}");

                      // Actualizar datos del conductor
                      await requests.child(Common.id).update({
                        "conductor": Common.name,
                        "cel_conductor": Common.phone,
                      });

                      await back.child(Common.id).update({
                        "conductor": Common.name,
                        "cel_conductor": Common.phone,
                      });

                      await disponibles.child(Common.id).remove();

                      double total = double.tryParse(Common.total) ?? 0;
                      double porcentaje = Common.porcentaje.toDouble();
                      double descuento = (porcentaje / 100) * total;

                      Common.saldo = Common.saldo - descuento;
                      Common.saldo =
                          double.parse(Common.saldo.toStringAsFixed(1));

                      await userRef.update({
                        "saldo": Common.saldo,
                        "respaldo_saldo": Common.saldo,
                        "servicio": Common.id,
                      });

                      Common.idR = Common.id;
                      Common.nombreR = Common.nombreCliente;
                      Common.origenR = Common.direccionOrigen;
                      Common.destinoR = Common.direccionDestino;
                      Common.detalleR =
                          'Nombre: ${Common.nombreR}\n\nOrigen: ${Common.direccionOrigen}\nDestino: ${Common.direccionDestino}\n\n${Common.total}';
                      Common.latitudOrigen = Common.latitud;
                      Common.longitudOrigen = Common.longitud;

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Mapa()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'TOMAR SERVICIO ${Common.total}',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 181, 242, 51),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),

                // Row con botones de ajuste de precio

                // Botón para actualizar el precio
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> leerServicio() async {
    final DatabaseReference databaseRef =
        FirebaseDatabase.instance.ref('TomarPedido/${Common.id}');

    try {
      print("Solicitando datos de Firebase...");
      final DataSnapshot snapshot = await databaseRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        print('Datos obtenidos de Firebase: $data');

        setState(() {
          Common.direccionOrigen = data['origen'] ?? '';
          Common.direccionDestino = data['destino'] ?? '';
          Common.latitudOrigen = data['latitud_origen'];
          Common.longitudOrigen = data['longitud_origen'];
          Common.latitudDestino = data['latitud_destino'];
          Common.longitudDestino = data['longitud_destino'];
          Common.total = data['precio'] ?? '';
          Common.precio = data['precio'] ?? '';
          Common.nombreCliente = data['nombre'];

          LatLng origen = LatLng(Common.latitudOrigen, Common.longitudOrigen);
          LatLng destino =
              LatLng(Common.latitudDestino, Common.longitudDestino);

          print(
              "Llamando a marcarRuta con origen: $origen y destino: $destino");
          agregarMarcadores(origen, destino);
          marcarRuta(origen, destino);
        });

        print("Datos leídos correctamente desde Firebase.");
      } else {
        print("No se encontraron datos en el nodo especificado. ${Common.id}");
      }
    } catch (e) {
      print("Error al leer datos desde Firebase: $e");
    }
  }
}
