import 'dart:io';

import 'package:cien_conductor/common.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
DatabaseReference realtime = FirebaseDatabase.instance.ref("User");

Future<bool> uploadImagen(File image) async {
  final String namefile = image.path.split("/").last;
  final Reference ref = storage.ref().child("images").child(namefile);
  final UploadTask uploadTask = ref.putFile(image);
  final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);
  final String url = await snapshot.ref.getDownloadURL();
  print(url);
  Common.foto = url;
  realtime.child(Common.phone).update({
    "foto": url,
  });

  return false;
}
