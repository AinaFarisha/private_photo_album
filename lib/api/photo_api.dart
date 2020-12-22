import 'dart:io';

import 'package:private_photo_album/model/photo.dart';
import 'package:private_photo_album/notifier/photo_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';



getPhotos(PhotoNotifier photoNotifier) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('Photos')
      .orderBy("createdAt", descending: true)
      .get();

  List<Photo> _photoList = [];

  snapshot.docs.forEach((document) {
    Photo photo = Photo.fromMap(document.data());
    _photoList.add(photo);
  });

  photoNotifier.photoList = _photoList;
}

uploadPhoto(Photo photo, bool isUpdating, File localFile, Function photoUploaded) async {
  if (localFile != null) {
    print("uploading image");

    var fileExtension = path.extension(localFile.path);
    print(fileExtension);

    var uuid = Uuid().v4();

    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('Photos/$uuid$fileExtension');

    await firebaseStorageRef.putFile(localFile).whenComplete(() => null).catchError((onError) {
      print(onError);
      return false;
    });

    String url = await firebaseStorageRef.getDownloadURL();
    print("download url: $url");
    _uploadPhoto(photo, isUpdating, photoUploaded, imageUrl: url);
  } else {
    print('...skipping image upload');
    _uploadPhoto(photo, isUpdating, photoUploaded);
  }
}

_uploadPhoto(Photo photo, bool isUpdating, Function photoUploaded, {String imageUrl}) async {
  CollectionReference photoRef = FirebaseFirestore.instance.collection('Photos');

  if (imageUrl != null) {
    photo.image = imageUrl;
    
  }

  if (isUpdating) {
    photo.updatedAt = Timestamp.now();

    await photoRef.doc(photo.id).update(photo.toMap());

    photoUploaded(photo);
    print('updated photo with id: ${photo.id}');
  } else {
    photo.createdAt = Timestamp.now();

    DocumentReference documentRef = await photoRef.add(photo.toMap());

    photo.id = documentRef.id;

    print('uploaded photo successfully: ${photo.toString()}');

    await documentRef.set(photo.toMap(), SetOptions(merge: true));

    photoUploaded(photo);
  }
}




