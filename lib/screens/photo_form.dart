import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:private_photo_album/api/photo_api.dart';
import 'package:private_photo_album/model/photo.dart';
import 'package:private_photo_album/notifier/photo_notifier.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PhotoForm extends StatefulWidget {
final bool isUpdating;

 PhotoForm({@required this.isUpdating});

  @override
  _PhotoFormState createState() => _PhotoFormState();
}

class _PhotoFormState extends State<PhotoForm> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Photo _currentPhoto;
  String _imageUrl;
  File _imageFile;
  final picker = ImagePicker();
   
  @override
  void initState() {
    Firebase.initializeApp();
    super.initState();
    
    PhotoNotifier photoNotifier = Provider.of<PhotoNotifier>(context, listen: false);

    if (photoNotifier.currentPhoto != null) {
      _currentPhoto = photoNotifier.currentPhoto;
    } else {
      _currentPhoto = Photo();
    }

    _imageUrl = _currentPhoto.image;
  }
  

  _showImage() {
    if (_imageFile == null && _imageUrl == null) {
      return Text("image placeholder");
    } else if (_imageFile != null) {
      print('showing image from local file');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.file(
            _imageFile,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Change Image',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
            ),
            onPressed: () => _getLocalImage(context),
          )
        ],
      );
    } else if (_imageUrl != null) {
      print('showing image from url');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.network(
            _imageUrl,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Change Image',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
            ),
            onPressed: () => _getLocalImage(context),
          )
        ],
      );
    }
  }

  _getLocalImage(BuildContext context) async {
      return showDialog(context: context,builder: (BuildContext context){
          return AlertDialog(
            title: Text("Complete action using:"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child:  Text("Gallery"),
                    onTap: (){
                      _openGallery(context);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(10.0),),
                  GestureDetector(
                    child:  Text("Camera"),
                    onTap: (){
                      _openCamera(context);
                    },
                  ),
                ],
              )
            ),
          );
        });

  }

  _openCamera(BuildContext context) async {
    //File imageFile;
  final pickedFile= await picker.getImage(source: ImageSource.camera);
   if (pickedFile != null) {
      setState(() {
        _imageFile =File(pickedFile?.path);
      });
    }

  }

  _openGallery(BuildContext context) async {
    final pickedFile= await picker.getImage(source: ImageSource.gallery);
   if (pickedFile != null) {
      setState(() {
        _imageFile =File(pickedFile?.path);
      });
    }

  }

  Widget _buildDescField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Description'),
      initialValue: _currentPhoto.desc,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      onSaved: (String value) {
        _currentPhoto.desc = value;
      },
    );
  }

  // Widget _buildLocationField() {
  //   return TextFormField(
  //     decoration: InputDecoration(labelText: 'Location'),
  //     initialValue: _currentPhoto.location,
  //     keyboardType: TextInputType.text,
  //     style: TextStyle(fontSize: 20),
  //     onSaved: (String value) {
  //       _currentPhoto.location = value;
  //     },
  //   );
  // }


  _onPhotoUploaded(Photo photo) {
    PhotoNotifier photoNotifier = Provider.of<PhotoNotifier>(context, listen: false);
    photoNotifier.addPhoto(photo);
    Navigator.pop(context);
  }


  _savePhoto() {
    
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    print('form saved');


    uploadPhoto(_currentPhoto, widget.isUpdating, _imageFile, _onPhotoUploaded);

    print("name: ${_currentPhoto.desc}");
    // print("category: ${_currentPhoto.location}");
    print("_imageFile ${_imageFile.toString()}");
    print("_imageUrl $_imageUrl");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Photo Form'),
        backgroundColor: Colors.pink[300],
        ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(children: <Widget>[
            _showImage(),
            SizedBox(height: 16),
            Text(
              widget.isUpdating ? "Edit Photo" : "Create Photo",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 16),
            _imageFile == null && _imageUrl == null
                ? ButtonTheme(
                    child: RaisedButton(
                      onPressed: () => _getLocalImage(context),
                      child: Text(
                        'Add Image',
                        style: TextStyle(color: Colors.white,),
                      ),
                      color: Colors.pink[300],
                    ),
                  )
                : SizedBox(height: 0),
            _buildDescField(),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(8),
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            )
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          _savePhoto();
        },
        child: Icon(Icons.save),
        backgroundColor: Colors.pink[300],
        foregroundColor: Colors.white,
      ),
    );
  }
}
