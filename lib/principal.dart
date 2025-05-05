// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:cien_conductor/common.dart';
import 'package:cien_conductor/historial.dart';
import 'package:cien_conductor/login.dart';
import 'package:cien_conductor/mapa.dart';
import 'package:cien_conductor/perfil.dart';
import 'package:cien_conductor/saldo.dart';
import 'package:cien_conductor/servicios_curso.dart';
import 'package:cien_conductor/servicios_disponibles.dart';
import 'package:cien_conductor/servidor.dart';
import 'package:cien_conductor/unidades.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  static const kGoogleApiKey =
      "AIzaSyDZghHfi0xyU2rNHUYvMWmXDKXxxaTB-dM"; // Reemplaza con tu API Key
  TextEditingController _destinoController = TextEditingController();
  final Map<MarkerId, Marker> _markers = {};
  late Timer _timer;
  Set<Polyline> _rutaPolylines = {};
  final TextEditingController distanciaController = TextEditingController();
  final TextEditingController tiempoController = TextEditingController();
  final TextEditingController costoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    costoController.text = 'Costo: ';

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _obtenerUbicacionActual();
    });
  }

  @override
  void dispose() {
    costoController.dispose();
    super.dispose();
  }

  void _onMapTap(LatLng tappedPoint) {
    print('Tocaste en: ${tappedPoint.latitude}, ${tappedPoint.longitude}');
    getDestino(tappedPoint.latitude, tappedPoint.longitude);
  }

  Future<String> getDestino(double latitud, double longitud) async {
    var formattedAddress = 'nada';
    final apiKey = 'AIzaSyDZghHfi0xyU2rNHUYvMWmXDKXxxaTB-dM';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitud,$longitud&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final decodedResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      final results = decodedResponse['results'];
      if (results != null && results.isNotEmpty) {
        Common.direccionDestino = results[0]['formatted_address'];

        Common.latitudDestino = latitud;
        Common.longitudDestino = longitud;
        _destinoController.text = Common.direccionDestino;

        _addDestino(LatLng(latitud, longitud));

        _controller?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(latitud, longitud), 14));

        LatLng origen = LatLng(Common.latitud, Common.longitud);
        LatLng destino = LatLng(Common.latitudDestino, Common.longitudDestino);

        _obtenerRuta(origen, destino);

        return formattedAddress;
      } else {
        formattedAddress = response.statusCode.toString();
      }
    }
    return '';
  }

  Future<String> getOrigen(double latitud, double longitud) async {
    var formattedAddress = 'nada';
    final apiKey = 'AIzaSyDZghHfi0xyU2rNHUYvMWmXDKXxxaTB-dM';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitud,$longitud&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final decodedResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      final results = decodedResponse['results'];
      if (results != null && results.isNotEmpty) {
        Common.direccionOrigen = results[0]['formatted_address'];

        return formattedAddress;
      } else {
        formattedAddress = response.statusCode.toString();
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            /*ListTile(
              title: Text('Servidor'),
              onTap: () {
                // Lógica para mostrar servicios en curso
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Servidor()));
              },
            ),*/
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
            Common.saldo_habilitado == 'si'
                ? ListTile(
                    title: Text('Saldo'),
                    onTap: () {
                      Navigator.pop(context);
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
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                _controller = controller;
              });
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  Common.latitud, Common.longitud), // Coordenadas de ejemplo
              zoom: 14.0,
            ),
            markers: Set<Marker>.of(_markers.values),
            polylines: _rutaPolylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap: _onMapTap,
          ),
          Positioned(
            top: 36,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: Colors.black),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  maxLines: null,
                                  controller: _destinoController,
                                  decoration: InputDecoration(
                                    hintText: 'Selecciona destino',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                  ),
                                  textInputAction: TextInputAction
                                      .search, // Cambiado a search para el botón de búsqueda en el teclado
                                  onFieldSubmitted: (value) {
                                    _resultadoDestino(
                                        value); // Usa el valor enviado directamente
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  _resultadoDestino(_destinoController.text);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: TextField(
                      maxLines: null,
                      enabled: false,
                      controller: costoController,
                      decoration: InputDecoration(
                        border: InputBorder
                            .none, // Eliminar la línea negra inferior
                      ),
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (Common.foto == '') {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Completa tus datos de perfil para continuar"),
                        ));
                      } else {
                        if (Common.unidad == '') {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Comunicate al 4151512750 para que te asignen una unidad"),
                          ));
                        } else {
                          Common.precio = '${Common.costo}';
                          await getOrigen(Common.latitud, Common.longitud);
                          mostrarDatos(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black, // Letras blancas
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Bordes redondeados al 8
                      ),
                    ),
                    child: Text('Generar servicio'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resultadoDestino(String suggestion) async {
    String query = suggestion;
    String apiKey = 'AIzaSyDZghHfi0xyU2rNHUYvMWmXDKXxxaTB-dM';

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$query&components=country:MX&key=$apiKey';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'OK') {
        String address = data['results'][0]['formatted_address'];
        double lat = data['results'][0]['geometry']['location']['lat'];
        double lng = data['results'][0]['geometry']['location']['lng'];

        setState(() {
          _destinoController.text = address;
          Common.direccionDestino = address;
          Common.latitudDestino = lat;
          Common.longitudDestino = lng;
        });

        _addDestino(LatLng(lat, lng));

        _controller
            ?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14));

        LatLng origen = LatLng(Common.latitud, Common.longitud);
        LatLng destino = LatLng(Common.latitudDestino, Common.longitudDestino);

        _obtenerRuta(origen, destino);

        print('Dirección: $address');
      } else {
        print('No se encontró la dirección: $query');
      }
    } else {
      print('Error al obtener datos de geocodificación.');
    }
  }

  void _addDestino(
    LatLng position,
  ) {
    final MarkerId markerId = MarkerId('Destino');
    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: Common.direccionDestino),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    setState(() {
      _markers[markerId] = marker;
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
      setState(() {
        _actualizarCoordenadas(position.latitude, position.longitude);
      });

      print('Ubicación guardada en Firebase correctamente');
    } catch (e) {
      print('Error al obtener la ubicación o guardar en Firebase: $e');
    }
  }

  void _actualizarCoordenadas(double latitud, double longitud) {
    setState(() {
      Common.latitud = latitud;
      Common.longitud = longitud;
      print('---- ${Common.latitud}, ${Common.longitud}');
    });
    _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(latitud, longitud), 14));
    //_markers.clear(); // Limpia todos los marcadores existentes
    //_addMarcadorUbicacionActual(); // Añade el nuevo marcador de ubicación actual
  }

  void _addMarcadorUbicacionActual() {
    final MarkerId markerId = MarkerId('UbicacionActual');
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(Common.latitud, Common.longitud),
      infoWindow: InfoWindow(title: 'Ubicación Actual'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    setState(() {
      _markers[markerId] = marker;
    });
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
        _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));

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
        costoController.text =
            'Distancia: $distanciaTexto, tiempo: $duracionTexto, \nCosto: \$${Common.costo}';
      } else {
        print('Error al obtener la ruta: ${data['status']}');
      }
    } else {
      print('Error en la solicitud de dirección: ${response.statusCode}');
    }
  }

// Función para decodificar puntos polilínea
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

  void mostrarDatos(BuildContext context) {
    TextEditingController nombre = TextEditingController();
    TextEditingController datos = TextEditingController();
    String message =
        'Origen: ${Common.direccionOrigen}\nDestino: ${Common.direccionDestino}\n\n${costoController.text}';
    datos.text = message;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Completa los datos'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nombre,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ingresa nombre del pasajero',
                  ),
                ),
                TextField(
                  controller: datos,
                  enabled: false,
                  maxLines: null,
                  style: TextStyle(color: Colors.black, fontSize: 12),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.green),
                    labelText: 'Información',
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Cierra el diálogo
                      },
                      child: Text('Cerrar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async {
                        if (nombre.text == '') {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Ingresa nombre del pasajero para continuar"),
                          ));
                        } else {
                          String nomb = nombre.text;
                          String mess = 'Nombre: $nomb\n\n$message';

                          DateTime ahora = DateTime.now();
                          String now = ahora.millisecondsSinceEpoch.toString();

                          DatabaseReference requests =
                              FirebaseDatabase.instance.ref("Requests");

                          DatabaseReference backup =
                              FirebaseDatabase.instance.ref("BackUpRequests");

                          DatabaseReference user =
                              FirebaseDatabase.instance.ref("User");

                          requests.child(now).update({
                            "id": now,
                            "hora": '$ahora',
                            "nombre": nomb,
                            "precio": Common.precio,
                            "costo": '\$${Common.precio}',
                            "total": 'Costo: \$${Common.precio}',
                            "origen": Common.direccionOrigen,
                            "destino": Common.direccionDestino,
                            "latitud_origen": Common.latitudOrigen,
                            "longitud_origen": Common.longitudOrigen,
                            "latitud_destino": Common.latitudDestino,
                            "longitud_destino": Common.longitudDestino,
                            "servicio": mess,
                            "conductor": Common.name,
                            "cel_conductor": Common.phone,
                          });

                          backup.child(now).update({
                            "id": now,
                            "hora": '$ahora',
                            "nombre": nomb,
                            "precio": Common.precio,
                            "costo": '\$${Common.precio}',
                            "total": 'Costo: \$${Common.precio}',
                            "origen": Common.direccionOrigen,
                            "destino": Common.direccionDestino,
                            "latitud_origen": Common.latitudOrigen,
                            "longitud_origen": Common.longitudOrigen,
                            "latitud_destino": Common.latitudDestino,
                            "longitud_destino": Common.longitudDestino,
                            "servicio": mess,
                            "conductor": Common.name,
                            "cel_conductor": Common.phone,
                          });

                          double total = double.tryParse(Common.precio) ?? 0;
                          double porcentaje = Common.porcentaje.toDouble();
                          double descuento = (porcentaje / 100) * total;

                          Common.saldo = Common.saldo - descuento;
                          Common.saldo =
                              double.parse(Common.saldo.toStringAsFixed(1));

                          await user.child(Common.phone).update({
                            "saldo": Common.saldo,
                            "respaldo_saldo": Common.saldo,
                            "servicio": now,
                          });

                          print(
                              '################ ${Common.precio} - ${Common.porcentaje} - ${Common.saldo} - ${Common.phone}');

                          Common.idR = now;
                          Common.nombreR = nomb;

                          Common.origenR = Common.direccionOrigen;
                          Common.destinoR = Common.direccionDestino;
                          Common.detalleR = mess;
                          Common.latitudOrigen = Common.latitud;
                          Common.longitudOrigen = Common.longitud;

                          Navigator.of(context).pop();

                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Mapa()));
                        }
                      },
                      child: Text('Generar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int calculateDiscountedSaldo(double saldo) {
    double saldoConDescuento = saldo * 0.8;
    return saldoConDescuento.round();
  }
}
