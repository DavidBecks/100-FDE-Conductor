// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'dart:math';

import 'package:cien_conductor/principal.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cien_conductor/common.dart';
import 'package:cien_conductor/register.dart';
import 'package:intl/intl.dart';

import 'package:cien_conductor/servicios_disponibles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final numero = TextEditingController();
  final contrasenia = TextEditingController();
  final registro = TextEditingController();
  bool obscureTexte = true;
  String _locationMessage = "";

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      Common.latitud = position.latitude;
      Common.longitud = position.longitude;
      print('Lat: ${position.latitude}, Long: ${position.longitude}');
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) {
      // Una vez que la ubicación esté obtenida, puedes leer las tarifas
      _mostrarDatos();
      _leerTarifas();
    }).catchError((error) {
      print("Error al obtener la ubicación: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
//f7f7f7
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isKeyboard)
              Image.asset(
                'assets/logo.jpg',
                height: 280,
              ),
            if (!isKeyboard)
              SizedBox(
                height: 40,
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 80.0),
              child: TextField(
                controller: numero,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintText: 'Número Telefónico',
                  fillColor: Colors.grey,
                  filled: true,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 80.0),
              child: TextField(
                /*onSubmitted: (value) async {
                  final ref = FirebaseDatabase.instance.ref();
                  final snapshot = await ref.child('User/${numero.text}').get();
                  if (numero.text.isEmpty || contrasenia.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text("Ingresa los datos completos para continuar"),
                    ));
                  } else {
                    if (snapshot.exists) {
                      if (snapshot.child('password').value ==
                          contrasenia.text) {
                        if (snapshot.child('isStaff').value == 'true') {
                          final nombre = snapshot.child('name').value;
                          Common.name = '$nombre';
                          Common.phone = numero.text;

                          if (snapshot.child('unidad').exists) {
                            Common.unidad =
                                snapshot.child('unidad').value.toString();
                          }
                          if (snapshot.child('foto').exists) {
                            Common.unidad =
                                snapshot.child('foto').value.toString();
                          }

                          if (snapshot.child("saldo").exists) {
                            if (double.parse(
                                    snapshot.child("saldo").value.toString()) >
                                0) {
                              Common.saldo = double.parse(
                                  snapshot.child("saldo").value.toString());
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MapScreen()));

                              guardar(
                                  Common.name, Common.phone, contrasenia.text);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Sesión iniciada"),
                              ));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content: Center(
                                child: Text(
                                    "Comunicate al 4151512750 para agregar saldo a tu usuario"),
                              )));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Center(
                              child: Text(
                                  "Comunicate al 4151512750 para agregar saldo a tu usuario"),
                            )));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Comunicate al 2227500541 para activar tu usuario"),
                          ));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Contraseña incorrecta"),
                        ));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("Este usuario no se encuentra registrado"),
                      ));
                    }
                  }
                },*/
                controller: contrasenia,
                obscureText: obscureTexte,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintText: 'Contraseña',
                  fillColor: Colors.grey,
                  filled: true,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        obscureTexte =
                            !obscureTexte; // Invierte el estado actual
                      });
                    },
                    child: Icon(
                      obscureTexte == true
                          ? Icons.visibility
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 80.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage()));
                  },
                  child: Text(
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                    'Registrarme',
                  ),
                )),
            const SizedBox(height: 30),
            ButtonTheme(
              minWidth: 200.0,
              height: 56.0,
              child: ElevatedButton(
                onPressed: () async {
                  _getCurrentLocation();
                  final ref = FirebaseDatabase.instance.ref();
                  final snapshot = await ref.child('User/${numero.text}').get();
                  if (numero.text.isEmpty || contrasenia.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text("Ingresa los datos completos para continuar"),
                    ));
                  } else {
                    if (snapshot.exists) {
                      if (snapshot.child('password').value ==
                          contrasenia.text) {
                        if (snapshot.child('isStaff').value.toString() ==
                            'true') {
                          final nombre = snapshot.child('name').value;
                          Common.name = '$nombre';
                          Common.phone = numero.text;

                          if (snapshot.child('unidad').exists) {
                            Common.unidad =
                                snapshot.child('unidad').value.toString();
                          }
                          if (snapshot.child('foto').exists) {
                            Common.foto =
                                snapshot.child('foto').value.toString();
                          }
                          if (snapshot.child('flotilla').exists) {
                            Common.flotilla =
                                snapshot.child('flotilla').value.toString();
                          } else {
                            Common.flotilla = 'no';
                          }
                          if (snapshot.child('saldo').exists) {
                            Common.saldo = double.parse(
                                snapshot.child('saldo').value.toString());
                            Common.saldo_habilitado = 'si';
                          } else {
                            Common.saldo_habilitado = 'no';
                          }

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ServiciosDisponibles()));

                          guardar(Common.name, Common.phone, contrasenia.text);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Sesión iniciada"),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Comunicate al 4151512750 para activar tu usuario"),
                          ));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Contraseña incorrecta"),
                        ));
                      }
                    } else {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Este usuario -${numero.text}- no se encuentra registrado"),
                      ));
                    }
                  }
                },
                child: Text(
                  "Iniciar Sesión",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      )),
    );
  }

  Future<void> guardar(String nombre, String numero, String contrasenia) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('nombre', nombre);
    await prefs.setString('numero', numero);
    await prefs.setString('contrasenia', contrasenia);
    await prefs.setString('terminos', 'si');
  }

  Future<void> _mostrarDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('nombre') != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Iniciando sesión"),
      ));
      Common.name = prefs.getString('nombre')!;
      Common.phone = prefs.getString('numero')!;

      _leerTarifas();

      if (mounted) {
        setState(() {});
      }

      numero.text = Common.phone;
      Common.contrasenia = prefs.getString('contrasenia')!;

      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('User/${Common.phone}').get();
      if (snapshot.exists) {
        if (snapshot.child('isStaff').value.toString() == 'true') {
          if (snapshot.child('password').value == Common.contrasenia) {
            if (snapshot.child('unidad').exists) {
              Common.unidad = snapshot.child('unidad').value.toString();
            }
            if (snapshot.child('foto').exists) {
              Common.foto = snapshot.child('foto').value.toString();
            }
            if (snapshot.child('flotilla').exists) {
              Common.flotilla = snapshot.child('flotilla').value.toString();
            } else {
              Common.flotilla = 'no';
            }
            if (snapshot.child('saldo').exists) {
              Common.saldo =
                  double.parse(snapshot.child('saldo').value.toString());
              Common.saldo_habilitado = 'si';
            } else {
              Common.saldo_habilitado = 'no';
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ServiciosDisponibles()));

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Sesión iniciada"),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Center(
              child: Text("Contraseña incorrecta"),
            )));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Comunicate al 4151512750 para activar tu usuario"),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Center(
          child: Text("Este usuario no se encuentra registrado "),
        )));
      }
    }
  }

  Future<void> _leerTarifas() async {
    final ref = FirebaseDatabase.instance.ref();

    try {
      final snapshot = await ref.child('Tarifas').get();
      if (snapshot.exists) {
        Common.cobertura_allende =
            int.parse(snapshot.child('cobertura_allende').value.toString());
        Common.cobertura_dolores =
            int.parse(snapshot.child('cobertura_dolores').value.toString());
        Common.cobertura_leon =
            int.parse(snapshot.child('cobertura_leon').value.toString());

        Common.kilometro_allende =
            int.parse(snapshot.child('kilometro_allende').value.toString());
        Common.kilometro_dolores =
            int.parse(snapshot.child('kilometro_dolores').value.toString());
        Common.kilometro_leon =
            int.parse(snapshot.child('kilometro_leon').value.toString());

        Common.minimo_allende =
            int.parse(snapshot.child('minimo_allende').value.toString());
        Common.minimo_dolores =
            int.parse(snapshot.child('minimo_dolores').value.toString());
        Common.minimo_leon =
            int.parse(snapshot.child('minimo_leon').value.toString());

        // Leer porcentaje y asignarlo a Common.porcentaje
        final porcentajeValue = snapshot.child('porcentaje').value;
        if (porcentajeValue != null) {
          Common.porcentaje = int.parse(porcentajeValue.toString());
        } else {
          Common.porcentaje = 0; // Valor por defecto si no existe
          print('Campo "porcentaje" no encontrado en Tarifas.');
        }

        print("Datos de tarifas asignados correctamente.");
      } else {
        print("El nodo Tarifas no existe.");
      }

      // Coordenadas de las ubicaciones
      const Map<String, List<double>> ubicaciones = {
        'Allende': [20.91430340550482, -100.74528063263956],
        'Dolores': [21.156590853342387, -100.93417745736886],
        'Leon': [21.123596193284133, -101.68607544016585],
      };

      // Coordenadas del usuario
      double userLat = Common.latitud;
      double userLng = Common.longitud;

      // Inicializar distancias
      Common.distanciaAllende = _calcularDistancia(userLat, userLng,
          ubicaciones['Allende']![0], ubicaciones['Allende']![1]);
      Common.distanciaDolores = _calcularDistancia(userLat, userLng,
          ubicaciones['Dolores']![0], ubicaciones['Dolores']![1]);
      Common.distanciaLeon = _calcularDistancia(
          userLat, userLng, ubicaciones['Leon']![0], ubicaciones['Leon']![1]);

      print(
          'Distancia a Allende: ${Common.distanciaAllende.toStringAsFixed(2)} km');
      print(
          'Distancia a Dolores: ${Common.distanciaDolores.toStringAsFixed(2)} km');
      print('Distancia a Leon: ${Common.distanciaLeon.toStringAsFixed(2)} km');

      // Determinar la tarifa más cercana
      String tarifaCercana = '';
      String tarifa = '';
      double distanciaMinima = double.infinity;

      ubicaciones.forEach((nombre, latLng) {
        final distancia =
            _calcularDistancia(userLat, userLng, latLng[0], latLng[1]);
        if (distancia < distanciaMinima) {
          distanciaMinima = distancia;
          tarifaCercana = nombre;
        }
      });

      // Asignar tarifas según la ubicación más cercana
      if (tarifaCercana == 'Allende') {
        tarifa = 'San Miguel de Allende';
        Common.cobertura = Common.cobertura_allende;
        Common.kilometro = Common.kilometro_allende;
        Common.minimo = Common.minimo_allende;
      } else if (tarifaCercana == 'Dolores') {
        tarifa = 'Dolores Hidalgo';
        Common.cobertura = Common.cobertura_dolores;
        Common.kilometro = Common.kilometro_dolores;
        Common.minimo = Common.minimo_dolores;
      } else if (tarifaCercana == 'Leon') {
        tarifa = 'Leon';
        Common.cobertura = Common.cobertura_leon;
        Common.kilometro = Common.kilometro_leon;
        Common.minimo = Common.minimo_leon;
      }

      Common.tarifa = tarifa;
      print('Tarifa seleccionada: ${Common.tarifa}');

      await ref
          .child('Versiones/${Common.phone}/${Common.name}')
          .set({'version': '5.4 android'});
      print('Versión escrita correctamente en Firebase.');
    } catch (e) {
      print('Error al leer/escribir en Firebase: $e');
    }
  }

  double _calcularDistancia(
      double lat1, double lon1, double lat2, double lon2) {
    const double radioTierra = 6371; // Radio de la Tierra en kilómetros
    final double dLat = _gradosARadianes(lat2 - lat1);
    final double dLon = _gradosARadianes(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_gradosARadianes(lat1)) *
            cos(_gradosARadianes(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radioTierra * c;
  }

  /// Convertir grados a radianes
  double _gradosARadianes(double grados) {
    return grados * pi / 180;
  }
}
