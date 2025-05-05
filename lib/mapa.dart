// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';

import 'package:cien_conductor/principal.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cien_conductor/common.dart';
import 'package:cien_conductor/servicios_curso.dart';
import 'package:cien_conductor/servicios_disponibles.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Mapa extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<Mapa> {
  late GoogleMapController mapController;
  late Timer _timer;

  final LatLng _marker1 = LatLng(Common.latitudOrigen, Common.longitudOrigen);
  final LatLng _marker2 = LatLng(Common.latitudDestino, Common.longitudDestino);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Polyline> _rutaPolylines = {};

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _obtenerRuta(LatLng origen, LatLng destino) async {
    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origen.latitude},${origen.longitude}&'
        'destination=${destino.latitude},${destino.longitude}&'
        'key=AIzaSyDZghHfi0xyU2rNHUYvMWmXDKXxxaTB-dM';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'OK') {
        List<LatLng> puntosRuta =
            _decodePoly(data['routes'][0]['overview_polyline']['points']);

        if (!mounted) return;
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
        //_controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
      } else {
        print('Error al obtener la ruta: ${data['status']}');
      }
    } else {
      print('Error en la solicitud de dirección: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    LatLng origen = LatLng(Common.latitud, Common.longitud);
    LatLng destino = LatLng(Common.latitudDestino, Common.longitudDestino);
    _obtenerRuta(origen, destino);
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _obtenerUbicacionActual();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // 👈 Cancela el timer
    super.dispose();
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

      if (!mounted) return;
      _actualizarCoordenadas(position.latitude, position.longitude);

      print('Ubicación guardada en Firebase correctamente');
    } catch (e) {
      print('Error al obtener la ubicación o guardar en Firebase: $e');
    }
  }

  void _actualizarCoordenadas(double latitud, double longitud) {
    if (!mounted) return;
    setState(() {
      Common.latitud = latitud;
      Common.longitud = longitud;
      print('---- ${Common.latitud}, ${Common.longitud}');
    });
    mapController.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(latitud, longitud), 14));
    //_markers.clear(); // Limpia todos los marcadores existentes
    //_addMarcadorUbicacionActual(); // Añade el nuevo marcador de ubicación actual
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(Common.latitud, Common.longitud),
              zoom: 14.0,
            ),
            markers: {
              Marker(
                markerId: MarkerId('marker2'),
                position: _marker2,
                infoWindow: InfoWindow(
                  title: 'Destino',
                  snippet: Common.destinoR, // Añadir descripción
                ),
              ),
            },
            polylines: _rutaPolylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            left: 16.0,
            right: 16.0,
            bottom: 60.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      Common.foto,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Common.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        Common.unidad,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: const Color.fromARGB(255, 5, 88, 8)),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 36.0,
            left: 16.0,
            right: 16.0,
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      Common.nombreR,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold, // Letra más ancha
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Origen: ${Common.origenR}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600, // Letra más ancha
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Destino: ${Common.destinoR}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600, // Letra más ancha
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      Common.precio,
                      style: TextStyle(
                        fontSize: 28,
                        color: const Color.fromARGB(255, 16, 173, 21),
                        fontWeight: FontWeight.bold, // Letra más ancha
                      ),
                      textAlign: TextAlign.center,
                    ),
                    /*GestureDetector(
                     //onTap: () => _launchCaller(Common.numeroR),
                      child: Text(
                        Common.numeroR,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold, // Letra más ancha
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),*/
                  ],
                )),
          ),
          Positioned(
            bottom: 10.0,
            left: 16.0,
            child: ElevatedButton(
              onPressed: () {
                _openGoogleMaps(Common.latitud, Common.longitud,
                    Common.latitudDestino, Common.longitudDestino);
                //_showGooglemaps(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green, // Letras blancas
                textStyle: TextStyle(
                  fontSize: 16, // Tamaño de letra 16
                  fontWeight: FontWeight.bold, // Letra más ancha
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Bordes redondeados
                ),
              ),
              child: Text('Google Maps'),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 16.0,
            child: ElevatedButton(
              onPressed: () {
                _openWaze(Common.latitudDestino, Common.longitudDestino);
                //_showWAZE(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green, // Letras blancas
                textStyle: TextStyle(
                  fontSize: 16, // Tamaño de letra 16
                  fontWeight: FontWeight.bold, // Letra más ancha
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Bordes redondeados
                ),
              ),
              child: Text('      WAZE      '),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            right: 10, bottom: 64.0), // Ajusta la distancia hacia arriba
        child: FloatingActionButton(
          onPressed: () {
            _showDetalle(context);
          },
          backgroundColor: Colors.red,
          child: Icon(Icons.info),
        ),
      ),
    );
  }

  void _launchCaller(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showDetalle(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  'Detalle del servicio',
                  textAlign: TextAlign.justify,
                ),
                Text(
                  Common.detalleR,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Text(
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  'Conductor',
                  textAlign: TextAlign.justify,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    Common.foto,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  Common.name,
                  textAlign: TextAlign.justify,
                ),
                Text(
                  Common.phone,
                  textAlign: TextAlign.justify,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  'Unidad',
                  textAlign: TextAlign.justify,
                ),
                Text(
                  Common.unidad,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // 1. Primero guarda el context
                        final parentContext = context;

                        // 2. Realiza todas las operaciones async ANTES de hacer pop
                        DatabaseReference borrarPendiente = FirebaseDatabase
                            .instance
                            .ref("Requests")
                            .child(Common.idR);
                        await borrarPendiente.remove();

                        DatabaseReference userServicio = FirebaseDatabase
                            .instance
                            .ref("User")
                            .child(Common.phone)
                            .child("servicio");
                        await userServicio.remove();

                        if (!mounted) return;

                        // 3. Cierra el diálogo una vez que todo terminó
                        Navigator.of(parentContext).pop();

                        // 4. Luego puedes usar el context seguro
                        Navigator.push(
                          parentContext,
                          MaterialPageRoute(
                            builder: (context) => ServiciosDisponibles(),
                          ),
                        );

                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          SnackBar(
                            content: Text("Servicio finalizado correctamente"),
                          ),
                        );
                      },
                      child: Text('Finalizar servicio'),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cerrar'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGooglemaps(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecciona una opción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  DatabaseReference curso = FirebaseDatabase.instance
                      .ref("Requests")
                      .child(Common.idR);
                  curso.update({"status": 'En camino al origen'});
                  _openGoogleMaps(Common.latitud, Common.longitud,
                      Common.latitudOrigen, Common.longitudOrigen);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Letras blancas
                  backgroundColor: Colors.black, // Fondo negro
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Bordes redondeados
                  ),
                ),
                child: Text('      IR A ORIGEN      '),
              ),
              SizedBox(height: 16.0), // Espacio entre los botones
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  DatabaseReference curso = FirebaseDatabase.instance
                      .ref("Requests")
                      .child(Common.idR);
                  curso.update({"status": 'En camino al destino'});
                  _openGoogleMaps(Common.latitud, Common.longitud,
                      Common.latitudDestino, Common.longitudDestino);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Letras blancas
                  backgroundColor: Colors.black, // Fondo negro
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Bordes redondeados
                  ),
                ),
                child: Text('    IR A DESTINO    '),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWAZE(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecciona una opción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  DatabaseReference curso = FirebaseDatabase.instance
                      .ref("Requests")
                      .child(Common.idR);
                  curso.update({"status": 'En camino al origen'});
                  _openWaze(Common.latitudOrigen, Common.longitudOrigen);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Letras blancas
                  backgroundColor: Colors.black, // Fondo negro
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Bordes redondeados
                  ),
                ),
                child: Text('      IR A ORIGEN      '),
              ),
              SizedBox(height: 16.0), // Espacio entre los botones
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  DatabaseReference curso = FirebaseDatabase.instance
                      .ref("Requests")
                      .child(Common.idR);
                  curso.update({"status": 'En camino al destino'});
                  _openWaze(Common.latitudDestino, Common.longitudDestino);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Letras blancas
                  backgroundColor: Colors.black, // Fondo negro
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Bordes redondeados
                  ),
                ),
                child: Text('    IR A DESTINO    '),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openGoogleMaps(double originLatitude, double originLongitude,
      double destinationLatitude, double destinationLongitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$originLatitude,$originLongitude&destination=$destinationLatitude,$destinationLongitude&travelmode=driving';
    final Uri uri = Uri.parse(url);
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWaze(
      double destinationLatitude, double destinationLongitude) async {
    final url =
        'https://waze.com/ul?ll=$destinationLatitude,$destinationLongitude&navigate=yes';
    final Uri uri = Uri.parse(url);
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> puntos = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1e5;
      double longitude = lng / 1e5;
      puntos.add(LatLng(latitude, longitude));
    }

    return puntos;
  }

// Función para crear límites que contienen todos los puntos de la ruta
// Función para crear límites que contienen todos los puntos de la ruta
  LatLngBounds _crearLimitesParaRuta(List<LatLng> puntosRuta) {
    double minLat = puntosRuta
        .map((LatLng point) => point.latitude)
        .reduce((min, value) => value < min ? value : min);
    double maxLat = puntosRuta
        .map((LatLng point) => point.latitude)
        .reduce((max, value) => value > max ? value : max);
    double minLng = puntosRuta
        .map((LatLng point) => point.longitude)
        .reduce((min, value) => value < min ? value : min);
    double maxLng = puntosRuta
        .map((LatLng point) => point.longitude)
        .reduce((max, value) => value > max ? value : max);

    LatLng southwest = LatLng(minLat, minLng);
    LatLng northeast = LatLng(maxLat, maxLng);

    return LatLngBounds(southwest: southwest, northeast: northeast);
  }
}
