// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cien_conductor/common.dart';
import 'package:cien_conductor/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final numero = TextEditingController();
  final contrasenia = TextEditingController();
  final nombre = TextEditingController();

  bool obscureTexte = true;

  @override
  Widget build(BuildContext context) {
//f7f7f7
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrarme'),
      ),
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_image.png'),
              fit: BoxFit.cover,
            ),
          ),
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
                    height: 30,
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80.0),
                  child: TextField(
                    controller: nombre,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintText: 'Nombre',
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
                    onSubmitted: (value) async {},
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
                  height: 10,
                ),
                const SizedBox(width: 260, height: 30),
                ButtonTheme(
                  minWidth: 200.0,
                  height: 56.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      final ref = FirebaseDatabase.instance.ref();
                      final snapshot =
                          await ref.child('User/${numero.text}').get();
                      if (numero.text.isEmpty ||
                          contrasenia.text.isEmpty ||
                          nombre.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Ingresa los datos completos para continuar"),
                        ));
                      } else {
                        if (numero.text.length == 10) {
                          if (snapshot.exists) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Este número ya se encuentra registrado"),
                            ));
                          } else {
                            DatabaseReference user =
                                FirebaseDatabase.instance.ref("User");
                            final date = DateTime.now();
                            user.child(numero.text).set({
                              "name": nombre.text,
                              "imagen":
                                  'https://firebasestorage.googleapis.com/v0/b/copia-servo.appspot.com/o/images%2Fperfil.png?alt=media&token=c0331739-e995-4826-915c-d9c2f98291cb',
                              "id": numero.text,
                              "direccion": 'No registrada',
                              "hora": '$date',
                              "phone": numero.text,
                              "password": contrasenia.text,
                              "isStaff": 'false',
                              "latitud": 0.0,
                              "longitud": 0.0,
                              "saldo": 0.0,
                              "usuario": 'Conductor'
                            });

                            Common.name = nombre.text;
                            Common.phone = numero.text;
                            Common.direccion = 'No registrada';
                            Common.latitud = 0.0;
                            Common.longitud = 0.0;

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Registro correcto"),
                            ));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Tu número debe ser a 10 digitos"),
                          ));
                        }
                      }
                    },
                    child: Text(
                      "Registrarme",
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
}
