import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Asegúrate de importar el archivo firebase_options.dart aquí
import 'screens/product_catalog.dart';
import 'screens/product_list.dart';
import 'screens/product_uploader.dart'; // Importa la ventana de ProductUploader
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/mostrar_carrito.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductList(),
       // Cambiar MyHomePage por ProductCatalog
    );
  }
}
