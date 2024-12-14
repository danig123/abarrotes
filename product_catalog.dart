import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Productos'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error al cargar los productos');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
           children: (snapshot.hasData && snapshot.data != null)
    ? snapshot.data!.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data =
            document.data() as Map<String, dynamic>;
        return ListTile(
          title: Text(data['nombre']),
          subtitle: Text(data['marca']),
          trailing: Text('\$${data['precio']}'),
        );
      }).toList()
    : [],

          );
        },
      ),
    );
  }
}
