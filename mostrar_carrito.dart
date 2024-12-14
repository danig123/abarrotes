import 'package:flutter/material.dart';
import 'cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MostrarCarrito extends StatefulWidget {
  @override
  _MostrarCarritoState createState() => _MostrarCarritoState();
}

class _MostrarCarritoState extends State<MostrarCarrito> {
  final CartService _cartService = CartService();
  bool _isConfirmingPurchase = false;
  Map<String, dynamic>? _cartDetails;
  double _totalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito de Compras'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _cartService.getCartDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    _cartDetails = snapshot.data!;
                    _calculateTotalAmount();
                    return ListView.builder(
                      itemCount: _cartDetails!.length,
                      itemBuilder: (context, index) {
                        final productId = _cartDetails!.keys.toList()[index];
                        final item = _cartDetails![productId];
                        final productData = item['productData'];
                        final quantity = item['quantity'];
                        final productName = productData['nombre'];
                        final productPrice = productData['precio'];
                        final totalPrice = productPrice * quantity;
                        return ListTile(
                          title: Text('Producto: $productName'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cantidad: $quantity'),
                              Text('Precio: \$${productPrice.toStringAsFixed(2)}'),
                              Text('Total: \$${totalPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showEditDialog(context, productName, quantity, productId),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _cartService.removeFromCart(productId);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                'Total a Pagar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '\$${_totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isConfirmingPurchase = true;
              });
            },
            child: Text('Confirmar Compra')
          ),
        ],
      ),
      floatingActionButton: _isConfirmingPurchase
          ? null
          : FloatingActionButton(
              onPressed: () => _confirmPurchase(context),
              child: Icon(Icons.shopping_cart),
            ),
    );
  }

  void _calculateTotalAmount() {
    _totalAmount = 0.0;
    _cartDetails!.forEach((productId, item) {
      final productData = item['productData'];
      final quantity = item['quantity'];
      final productPrice = productData['precio'];
      _totalAmount += productPrice * quantity;
    });
  }

  void _showEditDialog(BuildContext context, String productName, int currentQuantity, String productId) {
    int newQuantity = currentQuantity;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Cantidad'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Producto: $productName'),
                SizedBox(height: 20),
                Text('Cantidad Actual: $currentQuantity'),
                SizedBox(height: 10),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Nueva Cantidad'),
                  onChanged: (value) {
                    newQuantity = int.tryParse(value) ?? currentQuantity;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _cartService.updateQuantity(productId, newQuantity);
                Navigator.pop(context);
                setState(() {});
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmPurchase(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumen de la Compra:'),
                SizedBox(height: 10),
                if (_cartDetails != null)
                  for (var entry in _cartDetails!.entries)
                    Text('${entry.value['productData']['nombre']}: Cantidad ${entry.value['quantity']}'),
                SizedBox(height: 20),
                  Text('Monto Total: \$${_totalAmount.toStringAsFixed(2)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isConfirmingPurchase = false;
                });
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_cartDetails != null) {
                  _saveSaleToFirebase(_cartDetails!, _totalAmount);
                }
                _cartService.clearCart();
                Navigator.pop(context);
                setState(() {
                  _isConfirmingPurchase = false;
                });
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _saveSaleToFirebase(Map<String, dynamic> cartDetails, double totalAmount) {
    if (cartDetails != null) {
      FirebaseFirestore.instance.collection('ventas').add({
        'productos': cartDetails,
        'monto_total': totalAmount,
        'fecha': DateTime.now(),
      }).then((value) {
        print('Venta guardada en Firebase con ID: ${value.id}');
      }).catchError((error) {
        print('Error al guardar la venta en Firebase: $error');
      });
    }
  }
}
