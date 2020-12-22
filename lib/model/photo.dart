import 'package:cloud_firestore/cloud_firestore.dart';

class Photo {
  String id;
  String desc;
  String location;
  String image;
  Timestamp createdAt;
  Timestamp updatedAt;

  Photo();

  Photo.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    desc = data['description'];
    location = data['location'];
    image = data['image'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Description': desc,
      'Location': location,
      'image': image,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt
    };
  }
}
