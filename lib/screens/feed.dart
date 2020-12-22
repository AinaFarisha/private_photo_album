
import 'package:private_photo_album/api/photo_api.dart';
import 'package:private_photo_album/notifier/photo_notifier.dart';
import 'package:private_photo_album/screens/photo_form.dart';
import 'package:flutter/material.dart';
import 'package:private_photo_album/screens/theme_change.dart';
import 'package:provider/provider.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  void initState() {
    PhotoNotifier photoNotifier = Provider.of<PhotoNotifier>(context, listen: false);
    getPhotos(photoNotifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PhotoNotifier photoNotifier = Provider.of<PhotoNotifier>(context);

    Future<void> _refreshList() async {
      getPhotos(photoNotifier);
    }
    void _changeTheme() {
    showModalBottomSheet(context: context, builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: ThemeChange(),
        );
      });
  }

    print("building Feed");
    return Scaffold(
      appBar: AppBar(
        title: Text("Private Photo Album"),
        backgroundColor: Colors.pink[300],
        actions: <Widget>[
          
          FlatButton.icon(
            icon: Icon(Icons.settings),
            label: Text('Theme'),
            onPressed: () => _changeTheme(),
          ),
        ],
      ),
      body: new RefreshIndicator(
        
        child: Container(
          padding: EdgeInsets.all(4),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              return GridTile(
                child: Image.network(
                  photoNotifier.photoList[index].image != null
                      ? photoNotifier.photoList[index].image
                      : 'https://www.testingxperts.com/wp-content/uploads/2019/02/placeholder-img.jpg',
                   width: 120, 
                  fit: BoxFit.fitWidth,
                ),
                // title: Text(photoNotifier.photoList[index].desc),
                // subtitle: Text(photoNotifier.photoList[index].location),
              );
              
            },
            itemCount: photoNotifier.photoList.length,
            // separatorBuilder: (BuildContext context, int index) {
            //   return Divider(
            //     color: Colors.black,
            //   );
            // },
          ),
        ),
        onRefresh: _refreshList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          photoNotifier.currentPhoto = null;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return PhotoForm(
                 isUpdating: false,
              );
            }),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pink[300],
        foregroundColor: Colors.white,
      ),
    );
  }
}
