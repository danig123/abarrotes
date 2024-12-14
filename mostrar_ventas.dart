import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MostrarVentas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas Registradas'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('ventas').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar las ventas'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No hay ventas registradas'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var venta = snapshot.data!.docs[index];
              Map<String, dynamic> ventaData = venta.data() as Map<String, dynamic>;

              // Parsear la fecha de la venta
              Timestamp fechaVentaTimestamp = ventaData['fecha'] as Timestamp;
              DateTime fechaVenta = fechaVentaTimestamp.toDate();

              return ListTile(
                title: Text('Fecha: ${_formatDate(fechaVenta)}'),
                subtitle: Text('Monto Total: \$${ventaData['monto_total']}'),
                onTap: () => _showVentaDetails(context, ventaData),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Formatea la fecha en un formato legible
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showVentaDetails(BuildContext context, Map<String, dynamic> ventaData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la Venta'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${_formatDate(ventaData['fecha'].toDate())}'),
                Text('Monto Total: \$${ventaData['monto_total']}'),
                Text('Productos:'),
                for (var entry in ventaData['productos'].entries)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nombre: ${entry.value['productData']['nombre']}'),
                      Text('Marca: ${entry.value['productData']['marca']}'),
                      Text('Precio: \$${entry.value['productData']['precio']}'),
                      Text('Cantidad: ${entry.value['quantity']}'),
                      Divider(),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
