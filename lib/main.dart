import 'package:private_photo_album/model/theme.dart';
import 'package:private_photo_album/notifier/photo_notifier.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter/material.dart';
import 'package:private_photo_album/screens/pin_fingerprint.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PhotoNotifier>(create: (_) => PhotoNotifier()),
        ChangeNotifierProvider<ThemeChanger>(create: (_) => ThemeChanger(ThemeData.dark())),
      ],
      
      child: Container(
        child: new MaterialAppWithTheme(),
      ),
      
    );
    
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      title: 'My Photo Album',
      theme: theme.getTheme(),
      routes: {
        '/': (context) => PassCodeScreen(),
      },
      
    );
  }
}
