// ignore_for_file: prefer_const_constructors

import 'package:cien_conductor/common.dart';
import 'package:cien_conductor/upload_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Perfil extends StatefulWidget {
  @override
  _Categorias createState() => _Categorias();
}

Future<XFile?> getFoto() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.front,
  );
  Common.imagen_to_upload = File(image!.path);
  final uploaded = await uploadImagen(Common.imagen_to_upload!);
  return image;
}

class _Categorias extends State<Perfil> {
  TextEditingController nombreCompletoController = TextEditingController();

  TextEditingController telefonoController = TextEditingController();

  @override
  void initState() {
    nombreCompletoController.text = Common.name;

    telefonoController.text = Common.phone;

    super.initState();
    print(
        '${Common.name} jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj ${Common.vigencia}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors
              .white, // Establece el color del ícono de retroceso a blanco
        ),
        title: Text(
          'Cambiar foto',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () async {
                    final imagen = await getFoto();
                    setState(() {
                      Common.imagen_to_upload = File(imagen!.path);
                    });
                  },
                  child: ClipOval(
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: Common.foto == ''
                          ? Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/mind-forge-horizon-lite.appspot.com/o/images%2Fcamara.png?alt=media&token=fc882c36-dd24-4629-99c1-14e1708e16f6',
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              Common.foto,
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: nombreCompletoController,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                TextField(
                  enabled: false,
                  controller: telefonoController,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Teléfono (Bloqueado)',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final uploaded = await uploadInfo();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Información actualizada"),
                      ),
                    );
                  },
                  child: Text('Guardar cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> uploadImagen(File image) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    DatabaseReference realtime = FirebaseDatabase.instance.ref("User");

    final String namefile = image.path.split("/").last;
    final Reference ref = storage.ref().child("images").child(namefile);
    final UploadTask uploadTask = ref.putFile(image);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);
    final String url = await snapshot.ref.getDownloadURL();
    print(url);
    Common.foto = url;

    realtime.child(Common.phone).update({
      "imagen": url,
      "foto": url,
      /*"direccion": direccionController.text,
      "telefono2": telefonoController2.text,
      "padres": nombrePadresController.text,
      "fecha": fechaNacimientoController.text,
      "name": nombreCompletoController.text,*/
    });

    return false;
  }

  uploadInfo() async {
    DatabaseReference realtime = FirebaseDatabase.instance.ref("User");

    if (nombreCompletoController.text != '') {
      realtime.child(Common.phone).update({
        "name": nombreCompletoController.text,
      });
      Common.name = nombreCompletoController.text;
    }

    return false;
  }
}
